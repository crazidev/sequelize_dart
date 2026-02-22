import { checkConnection } from "../utils/checkUtils";
import { getSequelize, addTransaction, getTransaction, removeTransaction } from "../utils/state";
import { v4 as uuidv4 } from 'uuid';

export async function handleStartTransaction(): Promise<{ transactionId: string }> {
    const sequelize = getSequelize();
    checkConnection(sequelize);

    const transaction = await sequelize.startUnmanagedTransaction();
    const transactionId = uuidv4();
    addTransaction(transactionId, transaction);

    return { transactionId };
}

export async function handleCommitTransaction(params: { transactionId: string }): Promise<{ success: boolean }> {
    const transaction = getTransaction(params.transactionId);
    if (!transaction) {
        throw new Error(`Transaction not found: ${params.transactionId}`);
    }

    await transaction.commit();
    removeTransaction(params.transactionId);

    return { success: true };
}

export async function handleRollbackTransaction(params: { transactionId: string }): Promise<{ success: boolean }> {
    const transaction = getTransaction(params.transactionId);
    if (!transaction) {
        throw new Error(`Transaction not found: ${params.transactionId}`);
    }

    await transaction.rollback();
    removeTransaction(params.transactionId);

    return { success: true };
}