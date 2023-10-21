export default interface PasteSchema {
    id: string;
    contents: string;
    highlight: string;
    encrypted: boolean;
    burnAfterReading: boolean;
    createdAt: Date;
  }