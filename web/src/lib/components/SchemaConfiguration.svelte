<script lang="ts">
  import Self from '$lib/components/SchemaConfiguration.svelte';
  import AlbumPickerModal from '$lib/modals/AlbumPickerModal.svelte';
  import type { JSONSchemaProperty, SchemaConfig } from '$lib/types';
  import {
    Button,
    CodeBlock,
    Field,
    Input,
    Label,
    ListButton,
    modalManager,
    MultiSelect,
    NumberInput,
    Select,
    Switch,
    Text,
  } from '@immich/ui';
  import { t } from 'svelte-i18n';

  type Props = {
    schema: JSONSchemaProperty;
    root?: boolean;
    key?: string;
    config: SchemaConfig;
  };

  let { schema, key = '', root = false, config = $bindable() }: Props = $props();

  const label = $derived(schema.title ?? String(key));
  const description = $derived(schema.description);

  const onPickAlbum = async () => {
    const albums = await modalManager.show(AlbumPickerModal);
    if (!albums || albums.length === 0) {
      return;
    }

    setValue(albums[0].id);
  };

  const getBoolean = (defaultValue = false) => getValue<boolean>(defaultValue);
  const getString = () => getValue<string>();
  const getEnum = () => getValue<string[]>([]);
  const getNumber = () => getValue<number>();

  const getValue = <T,>(defaultValue?: T) => {
    return (root === true ? config : (config?.[key] ?? defaultValue)) as T;
  };
  const setValue = <T,>(value: T) => {
    if (root === true) {
      config = value;
    } else {
      if (config === undefined) {
        config = {};
      }

      config[key] = value;
    }
  };
</script>

<!-- Empty schema object -->
{#if Object.keys(schema).length === 0}
  <!-- noop -->
  <!-- nested configuration (also top level objects) -->
{:else if schema.type === 'object'}
  {#if !root}
    <div class="flex flex-col gap-2">
      <Label size="small" class="font-medium" {label}></Label>
      {#if description}
        <Text color="muted" size="small">{description}</Text>
      {/if}
    </div>
  {/if}
  <div class="flex flex-col gap-2 {root ? '' : 'border-l-3 border-primary-200 ps-2'}">
    {#each Object.entries(schema.properties ?? {}) as [childKey, childSchema], i (i)}
      <Self schema={childSchema} key={childKey} bind:config={getValue, setValue} />
    {/each}
  </div>
{:else if schema.uiHint === 'albumId'}
  {#if schema.array}
    {@const albumIds = getValue<string[]>([])}
    {#if albumIds}
      <Field {label} {description}>
        {#each albumIds as albumId (albumId)}
          <ListButton>{albumId}</ListButton>
        {/each}
      </Field>
    {:else}
      <div class="flex flex-col gap-2">
        <Label for="album-picker" size="small" class="font-medium" label={$t('album')}></Label>
        {#if description}
          <Text color="muted" size="small">{description}</Text>
        {/if}
        <Button size="small" color="secondary" onclick={onPickAlbum}>{$t('select_album')}</Button>
      </div>
    {/if}
  {:else}
    {@const albumId = getString()}
    {#if albumId}
      <Field {label} {description}>
        <Input value={albumId} readonly />
      </Field>
    {:else}
      <div class="flex flex-col gap-2">
        <Label for="album-picker" size="small" class="font-medium" label={$t('album')}></Label>
        {#if description}
          <Text color="muted" size="small">{description}</Text>
        {/if}
        <Button size="small" color="secondary" onclick={onPickAlbum}>{$t('select_album')}</Button>
      </div>
    {/if}
  {/if}
{:else if schema.enum && schema.array}
  <Field {label} {description}>
    <MultiSelect options={schema.enum} bind:values={getEnum, setValue} />
  </Field>
{:else if schema.enum}
  <Field {label} {description}>
    <Select options={schema.enum} bind:value={getString, setValue} />
  </Field>
{:else if schema.array}
  <Field {label} {description}>
    <Text>Arrays are not yet supported</Text>
  </Field>
{:else if schema.type === 'boolean'}
  <Field {label} {description}>
    <Switch bind:checked={() => getBoolean(schema.default ?? false), setValue} />
  </Field>
{:else if schema.type === 'number'}
  <Field {label} {description}>
    <NumberInput bind:value={getNumber, setValue} />
  </Field>
{:else if schema.type === 'string'}
  <Field {label} {description}>
    <Input bind:value={() => getValue<string>(), setValue} />
  </Field>
{:else}
  <Text>Unknown schema</Text>
  <CodeBlock code={JSON.stringify(schema, null, 2)} />
{/if}
