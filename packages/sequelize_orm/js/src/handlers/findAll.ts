import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import { toModelResponseArray, ModelResponse } from '../utils/modelResponse';
import { Attributes, FindOptions, Model } from '@sequelize/core';


type FindAllParams = {
  model: string;
  options?: FindOptions<Attributes<any>>;
};

export async function handleFindAll(params: FindAllParams): Promise<ModelResponse[]> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const options = convertQueryOptions(params.options || {});

  const model = getModels().get(modelName);
  checkModelDefinition(model, modelName);

  const hasInclude = options.include && (Array.isArray(options.include) ? options.include.length > 0 : true);
  const findOptions = hasInclude ? { ...options, mapToModel: false } : { ...options, raw: true };

  const results: any[] = await model.findAll(findOptions);
  return toModelResponseArray(results);
}
