import { Client, Intents } from 'discord.js';

export async function bootstrap() {
    // Require the necessary discord.js classes
    const client: Client = new Client({ intents: [Intents.FLAGS.GUILDS] });
    client.once('ready', () => console.log('Ready!'));
    client.login(process.env.BOT_TOKEN);
}