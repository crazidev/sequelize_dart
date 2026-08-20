import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import { toModelResponseArray, ModelResponse } from '../utils/modelResponse';
import { Attributes, FindOptions } from '@sequelize/core';
import { now } from '../utils/timer';

type FindAllParams = {
  model: string;
  options?: FindOptions<Attributes<any>>;
  _timings?: Record<string, number>;
};

export async function handleFindAll(params: FindAllParams): Promise<ModelResponse[]> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const timings = params._timings;

  const tConvertStart = now();
  const options = convertQueryOptions(params.options || {});
  if (timings) {
    timings.convertMs = Math.round((now() - tConvertStart) * 1000) / 1000;
  }

  const model = getModels().get(modelName);
  checkModelDefinition(model, modelName);

  const hasInclude = options.include && (Array.isArray(options.include) ? options.include.length > 0 : true);
  const findOptions = hasInclude ? { ...options, mapToModel: false } : { ...options, raw: true };

  const tDbStart = now();
  const results: any[] = await model.findAll(findOptions);
  if (timings) {
    timings.dbMs = Math.round((now() - tDbStart) * 1000) / 1000;
  }

  const tSerializeStart = now();
  const response = toModelResponseArray(results);
  if (timings) {
    timings.serializeMs = Math.round((now() - tSerializeStart) * 1000) / 1000;
  }
  return response;
}

