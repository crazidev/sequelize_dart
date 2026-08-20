import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import {
  toModelResponse,
  toModelResponseArray,
  ModelResponse,
} from '../utils/modelResponse';
import { Model } from '@sequelize/core';
import { now } from '../utils/timer';

type CreateParams = {
  model: string;
  data?: Record<string, any> | Record<string, any>[];
  options?: any;
  _timings?: Record<string, number>;
};

export async function handleCreate(
  params: CreateParams,
): Promise<ModelResponse | ModelResponse[]> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const data = params.data || {};
  const timings = params._timings;

  const tConvertStart = now();
  const options = convertQueryOptions(params.options || {});
  if (timings) {
    timings.convertMs = Math.round((now() - tConvertStart) * 1000) / 1000;
  }

  const model = getModels().get(modelName);
  checkModelDefinition(model, modelName);

  // Support bulk create (array of data)
  if (Array.isArray(data)) {
    if (data.length === 0) {
      return [];
    }

    const tDbStart = now();
    // bulkCreate returns an array of instances
    const results: Model[] = await model.bulkCreate(data, options);
    if (timings) {
      timings.dbMs = Math.round((now() - tDbStart) * 1000) / 1000;
    }

    const tSerializeStart = now();
    const responseArray = toModelResponseArray(results);
    if (timings) {
      timings.serializeMs = Math.round((now() - tSerializeStart) * 1000) / 1000;
    }
    return responseArray;
  }

  // Single create
  const tDbStart = now();
  const result = await model.create(data, options);
  if (timings) {
    timings.dbMs = Math.round((now() - tDbStart) * 1000) / 1000;
  }

  const tSerializeStart = now();
  const response = toModelResponse(result);
  if (timings) {
    timings.serializeMs = Math.round((now() - tSerializeStart) * 1000) / 1000;
  }
  return response;
}

export const handleBulkCreate = handleCreate;


