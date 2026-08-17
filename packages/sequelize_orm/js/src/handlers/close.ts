import { clearState, getSequelize } from '../utils/state';

export async function handleClose(): Promise<{ closed: true }> {
  const sequelize = getSequelize();
  if (sequelize) {
    try {
      await Promise.race([
        sequelize.close(),
        new Promise((resolve) => setTimeout(resolve, 200)),
      ]);
    } catch (_) {
      // Ignore errors during close
    }
    clearState();
  }
  return { closed: true };
}
