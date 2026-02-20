const localtunnel = require('localtunnel');

let activeTunnel = null;
const OPTS = { port: 5001, subdomain: 'foodloop123xyz' };

async function startTunnel() {
    try {
        if (activeTunnel) {
            console.log('Closing existing tunnel...');
            activeTunnel.close();
        }

        console.log(`Starting LocalTunnel on port ${OPTS.port} with subdomain ${OPTS.subdomain}...`);
        activeTunnel = await localtunnel(OPTS);

        console.log(`Tunnel established: ${activeTunnel.url}`);

        activeTunnel.on('close', () => {
            console.log('Tunnel closed naturally. Restarting...');
            setTimeout(startTunnel, 2000);
        });

        activeTunnel.on('error', (err) => {
            console.error('Tunnel error:', err.message);
            setTimeout(startTunnel, 2000);
        });

    } catch (error) {
        console.error('Failed to create tunnel:', error.message);
        setTimeout(startTunnel, 5000);
    }
}

// Ping the tunnel every 10 seconds to detect silent drops (network switch).
setInterval(async () => {
    if (!activeTunnel) return;

    try {
        const res = await fetch(`${activeTunnel.url}/api/offers`);
        if (!res.ok && res.status === 503) {
            console.warn('Silent tunnel drop detected (503). Reconnecting...');
            startTunnel();
        }
    } catch (e) {
        console.warn('Network unreachable. Waiting for reconnect...');
        startTunnel();
    }
}, 10000);

// Global Error Handlers
process.on('uncaughtException', (err) => {
    console.error('Uncaught exception:', err);
    startTunnel();
});

startTunnel();
