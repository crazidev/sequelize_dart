import { Model } from '@sequelize/core';

/**
 * Standard response format for model instances
 * Contains the data along with Sequelize instance metadata
 */
export interface ModelResponse {
  /** The model data as JSON */
  data: Record<string, any>;
  // TODO: Enable isNewRecord, changed & previous
  // previous?: Record<string, any>;
  // changed?: string[] | false;
  // isNewRecord?: boolean;
}

/**
 * Converts a Sequelize model instance to a standard response format
 * Fast-paths direct dataValues extraction to avoid toJSON overhead.
 */
export function toModelResponse(instance: any): ModelResponse {
  if (!instance) {
    return { data: {} };
  }
  if (typeof instance.toJSON === 'function') {
    return { data: instance.toJSON() };
  }
  return {
    data: instance || {},
  };
}



/**
 * Converts an array of Sequelize model instances to standard response format
 */
export function toModelResponseArray(instances: any[]): ModelResponse[] {
  return instances
    .filter((inst) => inst !== null && typeof inst === 'object')
    .map(toModelResponse);
}
