import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import { toModelResponse, toModelResponseArray } from '../utils/modelResponse';

type AssociationParams = {
    sourceModel: string;
    primaryKeyValues: Record<string, any>;
    associationName: string;
    data?: any;
    targetOrKey?: any;
    save?: boolean;
    options?: any;
};

function capitalize(name: string): string {
    if (!name) return name;
    return name[0].toUpperCase() + name.slice(1);
}

function compactWhere(where: Record<string, any>): Record<string, any> {
    return Object.fromEntries(
        Object.entries(where || {}).filter(([, v]) => v !== undefined && v !== null),
    );
}

async function getSourceInstance(sourceModelName: string, pkValues: Record<string, any>, transaction?: any) {
    const models = getModels();
    const source = models.get(sourceModelName);
    checkModelDefinition(source, sourceModelName);
    const where = compactWhere(pkValues);
    const instance = await source.findOne({ where, transaction });
    if (!instance) {
        throw new Error(`Source instance of model "${sourceModelName}" with PK ${JSON.stringify(pkValues)} not found`);
    }
    return instance;
}

function findAssociationMethod(instance: any, type: string, name: string) {
    const capitalized = capitalize(name);
    const primary = `${type}${capitalized}`;
    if (typeof instance[primary] === 'function') return primary;

    // Try singular form if name ends with 's'
    if (name.endsWith('s')) {
        const singular = name.slice(0, -1);
        const secondary = `${type}${capitalize(singular)}`;
        if (typeof instance[secondary] === 'function') return secondary;
    }

    return null;
}

export async function handleAssociationGet(params: AssociationParams) {
    const sequelize = getSequelize();
    checkConnection(sequelize);
    const options = convertQueryOptions(params.options || {});
    const instance = await getSourceInstance(params.sourceModel, params.primaryKeyValues, options.transaction);

    const methodName = findAssociationMethod(instance, 'get', params.associationName);
    if (!methodName) {
        throw new Error(`Association getter for "${params.associationName}" not found on model "${params.sourceModel}"`);
    }

    const result = await (instance as any)[methodName](options);
    if (Array.isArray(result)) return toModelResponseArray(result);
    if (!result) return null;
    return toModelResponse(result);
}

export async function handleAssociationSet(params: AssociationParams) {
    const sequelize = getSequelize();
    checkConnection(sequelize);
    const options = convertQueryOptions(params.options || {});
    const instance = await getSourceInstance(params.sourceModel, params.primaryKeyValues, options.transaction);

    const methodName = findAssociationMethod(instance, 'set', params.associationName);
    if (!methodName) {
        throw new Error(`Association setter for "${params.associationName}" not found on model "${params.sourceModel}"`);
    }

    await (instance as any)[methodName](params.targetOrKey, { ...options, save: params.save });
}

export async function handleAssociationAdd(params: AssociationParams) {
    const sequelize = getSequelize();
    checkConnection(sequelize);
    const options = convertQueryOptions(params.options || {});
    const instance = await getSourceInstance(params.sourceModel, params.primaryKeyValues, options.transaction);

    const methodName = findAssociationMethod(instance, 'add', params.associationName);
    if (!methodName) {
        throw new Error(`Association adder for "${params.associationName}" not found on model "${params.sourceModel}"`);
    }

    await (instance as any)[methodName](params.targetOrKey, options);
}

export async function handleAssociationRemove(params: AssociationParams) {
    const sequelize = getSequelize();
    checkConnection(sequelize);
    const options = convertQueryOptions(params.options || {});
    const instance = await getSourceInstance(params.sourceModel, params.primaryKeyValues, options.transaction);

    const methodName = findAssociationMethod(instance, 'remove', params.associationName);
    if (!methodName) {
        throw new Error(`Association remover for "${params.associationName}" not found on model "${params.sourceModel}"`);
    }

    await (instance as any)[methodName](params.targetOrKey, options);
}

export async function handleAssociationCreate(params: AssociationParams) {
    const sequelize = getSequelize();
    checkConnection(sequelize);
    const options = convertQueryOptions(params.options || {});
    const instance = await getSourceInstance(params.sourceModel, params.primaryKeyValues, options.transaction);

    const methodName = findAssociationMethod(instance, 'create', params.associationName);
    if (!methodName) {
        throw new Error(`Association creator for "${params.associationName}" not found on model "${params.sourceModel}"`);
    }

    const result = await (instance as any)[methodName](params.data, options);
    return toModelResponse(result);
}
