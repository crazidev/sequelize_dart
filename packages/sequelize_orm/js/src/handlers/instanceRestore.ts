import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type InstanceRestoreParams = {
  model: string;
  primaryKeyValues: Record<string, any>;
  transactionId?: string;
};

export async function handleInstanceRestore(params: InstanceRestoreParams): Promise<void> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const primaryKeyValues = params.primaryKeyValues;

  const models = getModels();
  const ModelClass = models.get(modelName);
  checkModelDefinition(ModelClass, modelName);

  // Build the instance from primary key values
  const instance = ModelClass.build(primaryKeyValues, {
    isNewRecord: false,
  });

  const options = convertQueryOptions({ transactionId: params.transactionId });

  // Instance.restore returns void
  await instance.restore(options);
}
