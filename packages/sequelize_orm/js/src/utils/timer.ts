export const now = (): number =>
  typeof performance !== 'undefined' && performance.now
    ? performance.now()
    : Date.now();
