import { MongoClient } from 'mongodb';
import { env } from '$env/dynamic/private';
import type PasteSchema from "./paste-schema";

const client = new MongoClient(env.DB_URL);
await client.connect();

const db = client.db("paste69");

const pastes = db.collection<PasteSchema>("pastes");

export {
    db,
    pastes,
}