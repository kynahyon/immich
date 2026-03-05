<script lang="ts">
  import { searchPluginMethods, WorkflowTrigger, type PluginMethodResponseDto } from '@immich/sdk';
  import { BasicModal, ListButton, LoadingSpinner, Stack, Text } from '@immich/ui';
  import { onMount } from 'svelte';
  import { t } from 'svelte-i18n';

  type Props = {
    trigger: WorkflowTrigger;
    selectedKey?: string;
    onClose: (method?: PluginMethodResponseDto) => void;
  };

  const { trigger, selectedKey, onClose }: Props = $props();

  let loading = $state(true);
  let methods = $state<PluginMethodResponseDto[]>();

  onMount(async () => {
    methods = await searchPluginMethods({ trigger });
    loading = false;
  });
</script>

<BasicModal title={$t('add_step')} {onClose}>
  {#if loading}
    <div class="flex w-full place-content-center place-items-center">
      <LoadingSpinner />
    </div>
  {:else}
    <Stack>
      {#each methods as method (method.key)}
        <ListButton selected={method.key === selectedKey} onclick={() => onClose(method)}>
          <div class="grow text-start">
            <Text fontWeight="medium">{method.title}</Text>
            {#if method.description}
              <Text size="tiny" color="muted">{method.description}</Text>
            {/if}
          </div>
        </ListButton>
      {/each}
    </Stack>
  {/if}
</BasicModal>
