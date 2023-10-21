import { MongoClient } from 'mongodb';
import { env } from '$env/dynamic/private';
import type { Db, Collection } from 'mongodb';
import type PasteSchema from "./paste-schema";
import { get } from 'http';

// let client: MongoClient;
// let db: Db;
// let pastes: Collection<PasteSchema>;

// const connect  = async (url: string) => {
//     client = new MongoClient(url);
//     await client.connect();
//     const db = client.db("paste69");
//     pastes = db.collection<PasteSchema>("pastes");
// }

// export {
//     db,
//     pastes,
//     connect,
// }

interface Collections {
    pastes: Collection<PasteSchema>;
}

export class Mongo {
    private static instance: Promise<MongoClient> |  null = null;

    private constructor() {}

    public static getClient(): Promise<MongoClient> {
        if (!Mongo.instance) {
            Mongo.instance = MongoClient.connect(env.DB_URL);
        }

        return Mongo.instance;
    }

    public static async getDb(): Promise<Db> {
        const client = await Mongo.getClient();
        return client.db("paste69");
    }

    public static async getCollection<T extends PasteSchema>(name: string): Promise<Collection<T>> {
        const db = await Mongo.getDb();
        return db.collection<T>(name);
    }

    public static async getNamedCollection<name extends keyof Collections>(name: name): Promise<Collections[name]> {
        return Mongo.getCollection(name) as Promise<Collections[name]>;
    }
}