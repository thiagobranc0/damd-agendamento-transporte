-- CreateTable
CREATE TABLE "DriverNotification" (
    "id" TEXT NOT NULL,
    "rideId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "read" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DriverNotification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "DriverNotification_read_idx" ON "DriverNotification"("read");
