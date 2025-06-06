import { createEnv } from '@t3-oss/env-core';
import z from 'zod';

export const apiEnv = createEnv({
	server: {
		PORT: z.coerce.number().default(3001),
		NODE_ENV: z.enum(['development', 'production']),
		// DATABASE_URL: z.string().url(),
	},
	runtimeEnv: Bun.env,
	emptyStringAsUndefined: true,
});
