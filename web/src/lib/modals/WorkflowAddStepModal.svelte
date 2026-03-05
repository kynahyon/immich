<script lang="ts">
  import SchemaConfiguration from '$lib/components/SchemaConfiguration.svelte';
  import PluginMethodPicker from '$lib/modals/PluginMethodPicker.svelte';
  import { type JSONSchemaProperty, type SchemaConfig } from '$lib/types';
  import { WorkflowTrigger, type PluginMethodResponseDto, type WorkflowStepDto } from '@immich/sdk';
  import { Field, FormModal, IconButton, modalManager, Stack, Text, Textarea } from '@immich/ui';
  import { mdiPencilOutline } from '@mdi/js';
  import { t } from 'svelte-i18n';

  type Props = {
    trigger: WorkflowTrigger;
    onClose: (step?: WorkflowStepDto) => void;
  };

  const { trigger, onClose }: Props = $props();

  const onSubmit = () => {
    if (method) {
      onClose({ method: method.key, config, enabled: true });
    }
  };

  let method = $state<PluginMethodResponseDto>();
  let config = $state<SchemaConfig>({});
  let debug = $state(false);

  const onPickMethod = async () => {
    const selected = await modalManager.show(PluginMethodPicker, { trigger, selectedKey: method?.key });
    if (!selected) {
      return;
    }

    method = selected;
    config = selected.schema ? {} : null;
  };

  void onPickMethod();
</script>

{#if method}
  <FormModal title={$t('add_step')} {onClose} {onSubmit} disabled={!method} size="small">
    <div class="flex items-center justify-between gap-2">
      <div class="grow text-start">
        <Text fontWeight="medium">{method.title}</Text>
        {#if method.description}
          <Text size="tiny" color="muted">{method.description}</Text>
        {/if}
      </div>
      <IconButton
        icon={mdiPencilOutline}
        onclick={onPickMethod}
        variant="ghost"
        shape="round"
        color="secondary"
        aria-label={$t('edit')}
      />
    </div>

    {#if method.schema}
      <div class="mt-4 grow text-start">
        <Stack gap={4}>
          <SchemaConfiguration schema={method.schema as JSONSchemaProperty} bind:config root />

          {#if debug}
            <Field label={$t('preview')}>
              <Textarea readonly grow value={JSON.stringify({ method: method.key, config }, null, 2)} />
            </Field>
          {/if}
          <!-- <Text size="small" color="muted">{$t('no_configuration_needed')}</Text> -->
        </Stack>
      </div>
    {/if}
  </FormModal>
{/if}
