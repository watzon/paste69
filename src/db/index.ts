import { MongoClient } from 'mongodb';
import { DB_URL } from '$env/static/private';
import type PasteSchema from "./paste-schema";

const client = new MongoClient(DB_URL);
await client.connect();

const db = client.db("paste69");

const pastes = db.collection<PasteSchema>("pastes");

export {
    db,
    pastes,
}