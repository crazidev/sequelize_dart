import Sequelize, { ModelStatic, Transaction } from "@sequelize/core";

let sequelize: Sequelize | null = null;
const models = new Map<string, ModelStatic>();
const transactions = new Map<string, Transaction>();

let options: { hoistIncludeOptions: boolean; dialect: string; normalizeJsonTypes: boolean } = {
  hoistIncludeOptions: false,
  dialect: 'postgres',
  normalizeJsonTypes: true,
};

// Notification callback for SQL logging
// Set by bridge_server.ts (unified - detects stdio or Worker Thread mode)
let notificationCallback: ((notification: any) => void) | null = null;

export function setNotificationCallback(callback: (notification: any) => void): void {
  notificationCallback = callback;
}

export function sendNotification(notification: any): void {
  if (notificationCallback) {
    notificationCallback(notification);
  }
}

export function getOptions(): { hoistIncludeOptions: boolean; dialect: string; normalizeJsonTypes: boolean } {
  return options;
}

export function setOptions(
  newOptions: Partial<{ hoistIncludeOptions: boolean; dialect: string; normalizeJsonTypes: boolean }>,
): void {
  options = { ...options, ...newOptions };
}

export function getSequelize(): Sequelize {
  return sequelize!;
}

export function setSequelize(instance: Sequelize): void {
  sequelize = instance;
}

export function getModels(): Map<string, ModelStatic> {
  return models;
}

export function getTransactions(): Map<string, Transaction> {
  return transactions;
}

export function getTransaction(id: string): Transaction | undefined {
  return transactions.get(id);
}

export function addTransaction(id: string, transaction: Transaction): void {
  transactions.set(id, transaction);
}

export function removeTransaction(id: string): void {
  transactions.delete(id);
}

export function clearState(): void {
  if (sequelize) {
    sequelize = null;
  }
  models.clear();
  transactions.clear();
}

