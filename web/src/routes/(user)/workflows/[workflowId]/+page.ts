import { searchWorkflows } from '@immich/sdk';
import { redirect } from '@sveltejs/kit';
import { pluginManager } from '$lib/managers/plugin-manager.svelte';
import { Route } from '$lib/route';
import { authenticate } from '$lib/utils/auth';
import { getFormatter } from '$lib/utils/i18n';
import type { PageLoad } from './$types';

export const load = (async ({ url, params }) => {
  await authenticate(url);
  const [[workflow]] = await Promise.all([searchWorkflows({ id: params.workflowId }), pluginManager.ready()]);
  const $t = await getFormatter();

  if (!workflow) {
    redirect(307, Route.workflows());
  }

  return {
    workflow,
    meta: {
      title: $t('edit_workflow'),
    },
  };
}) satisfies PageLoad;
