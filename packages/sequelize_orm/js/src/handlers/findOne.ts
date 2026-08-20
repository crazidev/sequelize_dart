import { Attributes, FindOptions } from '@sequelize/core';
import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import { toModelResponse, ModelResponse } from '../utils/modelResponse';
import { now } from '../utils/timer';

type FindOneParams = {
  model: string;
  options?: FindOptions<Attributes<any>>;
  _timings?: Record<string, number>;
};

export async function handleFindOne(params: FindOneParams): Promise<ModelResponse | null> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const timings = params._timings;

  const tConvertStart = now();
  const options = convertQueryOptions(params.options || {});
  if (timings) {
    timings.convertMs = Math.round((now() - tConvertStart) * 1000) / 1000;
  }

  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  const hasInclude = options.include && (Array.isArray(options.include) ? options.include.length > 0 : true);
  const findOptions = hasInclude ? options : { ...options, raw: true };

  const tDbStart = now();
  const result: any = await model.findOne(findOptions);
  if (timings) {
    timings.dbMs = Math.round((now() - tDbStart) * 1000) / 1000;
  }

  const tSerializeStart = now();
  const response = result ? toModelResponse(result) : null;
  if (timings) {
    timings.serializeMs = Math.round((now() - tSerializeStart) * 1000) / 1000;
  }
  return response;
}

