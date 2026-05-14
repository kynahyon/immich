import { tick } from 'svelte';
import { viewTransitionManager } from '$lib/managers/ViewTransitionManager.svelte';
import { assetViewerManager } from '$lib/managers/asset-viewer-manager.svelte';

export async function startViewerTransition(
  heroAssetId: string,
  openViewer: () => void,
  activateHeroAsset: (assetId: string) => void,
  deactivateHeroAsset: () => void,
) {
  await viewTransitionManager.startTransition({
    types: ['viewer'],
    prepareOldSnapshot: () => {
      activateHeroAsset(heroAssetId);
    },
    performUpdate: async (signal) => {
      deactivateHeroAsset();
      const ready = assetViewerManager.untilNext('ViewerOpenTransitionReady', { signal });
      openViewer();
      await ready;
      assetViewerManager.emit('ViewerOpenTransition');
      await tick();
    },
  });
}
