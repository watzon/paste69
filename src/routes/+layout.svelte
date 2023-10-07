<script>
	import '../app.postcss';
	import { Modal, Toast, initializeStores } from '@skeletonlabs/skeleton';

	initializeStores();
</script>

<svelte:head>
	<script defer src={`//analytics.watzon.tech/matomo.js`}></script>
	<script>
		var _paq = window._paq = window._paq || [];
		/* tracker methods like "setCustomDimension" should be called before "trackPageView" */
		_paq.push(['trackPageView']);
		_paq.push(['enableLinkTracking']);
		(function() {
			var u="//analytics.watzon.tech/";
			_paq.push(['setTrackerUrl', u+'matomo.php']);
			_paq.push(['setSiteId', '1']);
			var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
			g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
		})();
	</script>
</svelte:head>

<Modal />
<Toast />
<slot />
