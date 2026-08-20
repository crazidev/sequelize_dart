import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import { now } from '../utils/timer';

type UpdateParams = {
  model: string;
  data: Record<string, any>;
  query?: any;
  _timings?: Record<string, number>;
};

export async function handleUpdate(params: UpdateParams): Promise<number> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const data = params.data;
  const timings = params._timings;

  const tConvertStart = now();
  const options = convertQueryOptions(params.query || {});
  if (timings) {
    timings.convertMs = Math.round((now() - tConvertStart) * 1000) / 1000;
  }

  if (!data || Object.keys(data).length === 0) {
    throw new Error('Data is required for update operation');
  }

  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  const tDbStart = now();
  // Sequelize update returns [affectedCount, affectedRows]
  // affectedCount is the number of rows affected
  const result = await model.update(data, options);
  if (timings) {
    timings.dbMs = Math.round((now() - tDbStart) * 1000) / 1000;
  }

  const affectedCount = result[0];

  if (typeof affectedCount === 'number') {
    return affectedCount;
  }

  // Fallback if result format is unexpected
  return 0;
}

