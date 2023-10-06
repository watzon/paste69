<script>
	import '../app.postcss';
	import { Modal, Toast, initializeStores } from '@skeletonlabs/skeleton';
	import {
		PUBLIC_GOOGLE_ANALYTICS_SITE_ID,
		PUBLIC_ACKEE_DOMAIN_ID,
		PUBLIC_ACKEE_URL,
		PUBLIC_MATOMO_SITE_ID,
		PUBLIC_MATOMO_URL,
		PUBLIC_PLAUSIBLE_DOMAIN,
		PUBLIC_PLAUSIBLE_URL
	} from '$env/static/public';

	initializeStores();
</script>

<svelte:head>
	{#if PUBLIC_GOOGLE_ANALYTICS_SITE_ID}
		<script
			async
			src={`https://www.googletagmanager.com/gtag/js?id=${PUBLIC_GOOGLE_ANALYTICS_SITE_ID}`}
		></script>
		<script>
			{@html `window.dataLayer = window.dataLayer || [];
			function gtag(){dataLayer.push(arguments);}
			gtag('js', new Date());
		  
			gtag('config', '${PUBLIC_GOOGLE_ANALYTICS_SITE_ID}');`}
		</script>
	{/if}

	{#if PUBLIC_PLAUSIBLE_DOMAIN}
		<script
			defer
			data-domain={PUBLIC_PLAUSIBLE_DOMAIN}
			src={`${PUBLIC_PLAUSIBLE_URL}/js/script.js`}
		></script>
	{/if}

	{#if PUBLIC_ACKEE_URL && PUBLIC_ACKEE_DOMAIN_ID}
		<script
			async
			src={`${PUBLIC_ACKEE_URL}/tracker.js`}
			data-ackee-server={PUBLIC_ACKEE_URL}
			data-ackee-domain-id={PUBLIC_ACKEE_DOMAIN_ID}
		></script>
	{/if}

	{#if PUBLIC_MATOMO_URL && PUBLIC_MATOMO_SITE_ID}
		<script defer src={`${PUBLIC_MATOMO_URL}/matomo.js`}></script>
		<script>
			{@html `
			var _paq = window._paq = window._paq || [];
			/* tracker methods like "setCustomDimension" should be called before "trackPageView" */
			_paq.push(['trackPageView']);
			_paq.push(['enableLinkTracking']);
			(function() {
			  var u="${PUBLIC_MATOMO_URL}/";
			  _paq.push(['setTrackerUrl', u+'matomo.php']);
			  _paq.push(['setSiteId', '${PUBLIC_MATOMO_SITE_ID}']);
			  var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
			  g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
			})();`}
		</script>
	{/if}
</svelte:head>

<Modal />
<Toast />
<slot />
