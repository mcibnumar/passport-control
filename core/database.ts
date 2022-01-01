import { PrismaClient } from "@prisma/client";

const prisma: PrismaClient = new PrismaClient();

function operation (cb) : Promise<void> {
  try {
    cb(prisma);
  }
  catch (e) {
    console.error(e);
  }
  finally {
    return prisma.$disconnect();
  }
}

export default operation;