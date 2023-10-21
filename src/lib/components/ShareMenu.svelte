<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    import { getModalStore, getToastStore } from '@skeletonlabs/skeleton';
    import type { ModalSettings } from '@skeletonlabs/skeleton';
	import { BrandFacebook, BrandMastodon, BrandMessenger, BrandTelegram, BrandTwitter, BrandWhatsapp, ClipboardCopy, Copy } from "svelte-tabler";

    export let pasteUrl: string;
    export let shareMessage: string = 'Check out this paste on Paste69: {url}'

    const dispatch = createEventDispatcher();
    const modalStore = getModalStore();
    const toastStore = getToastStore();

    const mastodonUrlModal: ModalSettings = {
        type: 'prompt',
        // Data
        title: 'Mastodon instance URL',
        valueAttr: { type: 'text', required: true, placeholder: 'https://mastodon.social' },
        // Returns the updated response value
        response: (r: string) => {
            // Strip everything but the host and tld
            const url = new URL(r);
            const host = url.host;
            window.open(`https://${host}/share?text=${encodeURIComponent(shareMessage)}`, '_blank');
        },
    };

    const shareOnMastodon = async () => modalStore.trigger(mastodonUrlModal);

    const copyUrl = () => {
        navigator.clipboard.writeText(pasteUrl);
        toastStore.trigger({
            message: 'Copied paste URL to clipboard.',
            background: 'variant-filled-success'
        });
    }

    $: shareMessage = shareMessage.replace('{url}', pasteUrl)
</script>

<div class="grid grid-cols-1 justify-center items-center py-6 px-4 bg-slate-800">
    <div class="flex flex-col items-center gap-4">
        <!-- Twitter Share Button -->
        <a
            class="p-2 bg-gray-900 rounded w-min"
            href={`https://twitter.com/intent/tweet?text=${encodeURIComponent(
                shareMessage
            )}`}
            target="_blank"
            rel="noopener noreferrer"
            title="Share on Twitter"
        >
            <BrandTwitter size="28" />
        </a>

        <!-- Facebook Share Button -->
        <a
            class="p-2 bg-gray-900 rounded w-min"
            href={`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(
                pasteUrl
            )}`}
            target="_blank"
            rel="noopener noreferrer"
            title="Share on Facebook"
        >
            <BrandFacebook size="28" />
        </a>

        <!-- Messenger Share Button -->
        <a
            class="p-2 bg-gray-900 rounded w-min"
            href={`https://www.facebook.com/dialog/send?app_id=521270401588372&link=${encodeURIComponent(
                pasteUrl
            )}&redirect_uri=${encodeURIComponent(
                pasteUrl
            )}&display=popup&quote=${encodeURIComponent(shareMessage)}`}
            target="_blank"
            rel="noopener noreferrer"
            title="Share on Messenger"
        >
            <BrandMessenger size="28" />
        </a>

        <!-- Whatsapp Share Button -->
        <a
            class="p-2 bg-gray-900 rounded w-min"
            href={`https://api.whatsapp.com/send?text=${encodeURIComponent(
                shareMessage
            )}`}
            target="_blank"
            rel="noopener noreferrer"
            title="Share on Whatsapp"
        >
            <BrandWhatsapp size="28" />
        </a>

        <!-- Telegram Share Button -->
        <a
            class="p-2 bg-gray-900 rounded w-min"
            href={`https://telegram.me/share/url?url=${encodeURIComponent(
                pasteUrl
            )}&text=${encodeURIComponent(shareMessage)}`}
            target="_blank"
            rel="noopener noreferrer"
            title="Share on Telegram"
        >
            <BrandTelegram size="28" />
        </a>

        <!-- Mastodon Share Button -->
        <button
            class="p-2 bg-gray-900 rounded w-min"
            title="Share on Mastodon"
            on:click={shareOnMastodon}
        >
            <BrandMastodon size="28" />
        </button>

        <!-- Copy URL Button -->
        <button
            class="p-2 bg-gray-900 rounded w-min"
            title="Copy URL"
            on:click={copyUrl}
        >
            <Copy size="28" />
        </button>

        <!-- Copy content button -->
        <button
            class="p-2 bg-gray-900 rounded w-min"
            title="Copy content"
            on:click={() => dispatch('copy')}
        >
            <ClipboardCopy size="28" />
        </button>
    </div>
</div>

