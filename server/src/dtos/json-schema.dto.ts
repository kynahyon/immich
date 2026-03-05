import z from 'zod';

export const JsonSchemaTypeSchema = z
  .enum(['string', 'number', 'integer', 'boolean', 'object'])
  .meta({ id: 'JsonSchemaType' });

export const JsonSchemaPropertySchema = z
  .object({
    type: JsonSchemaTypeSchema.optional().describe('Type'),
    description: z.string().optional().describe('Description'),
    default: z.any().optional().describe('Default value'),
    enum: z.array(z.string()).optional().describe('Valid choices for enum types'),
    array: z.boolean().optional().describe('Type is an array type'),
    required: z.array(z.string()).optional().describe('A list of required properties'),
    get properties() {
      return z.record(z.string(), JsonSchemaPropertySchema).optional();
    },
  })
  .meta({ id: 'JsonSchemaProperty' });

export const JsonSchemaSchema = z
  .object({
    type: JsonSchemaTypeSchema.optional(),
    properties: z.record(z.string(), JsonSchemaPropertySchema).optional(),
    required: z.array(z.string()).optional(),
    additionalProperties: z.boolean().optional(),
    description: z.string().optional(),
  })
  .meta({ id: 'PluginJsonSchema' });

export type JsonSchemaProperty = z.infer<typeof JsonSchemaPropertySchema>;
export type JsonSchema = z.infer<typeof JsonSchemaSchema>;
