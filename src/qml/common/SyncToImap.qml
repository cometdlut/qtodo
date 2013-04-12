/*
 *  Copyright 2013 Ruediger Gad
 *
 *  This file is part of Q To-Do.
 *
 *  Q To-Do is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Q To-Do is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Q To-Do.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import qtodo 1.0

Item {
    id: syncToImapItem

    property int imapAccountId: -1
    property string imapFolderName: "qtodo"
    property int imapMessageId: -1
    property string imapMessageSubject: "[QTODO] SimpleSync"
    property string imapSyncFile: ""

    function startSync() {
        imapAccountId = -1
        imapMessageId = -1
        imapSyncFile = ""
        syncToImapProgressDialog.currentValue = 0
        syncToImapProgressDialog.open()
        syncToImap()
    }

    function syncToImap() {
        var accIds = imapStorage.queryImapAccounts()
        console.log("Found " + accIds.length + " IMAP account(s).")

        syncToImapProgressDialog.currentValue++

        if (accIds.length === 1) {
            console.log("Found a single IMAP account. Using this for syncing.")
            console.log("IMAP account id is: " + accIds[0])
            imapAccountId = accIds[0]
            imapStorage.retrieveFolderList(imapAccountId)
        } else if (accIds.length === 0) {
            syncToImapProgressDialog.close()
            messageDialog.title = "No IMAP Account"
            messageDialog.message = "Please set up an IMAP e-mail account for syncing."
            messageDialog.open()
        } else if (accIds.length > 1) {
            syncToImapProgressDialog.close()
            messageDialog.title = "Multiple IMAP Accounts"
            messageDialog.message = "Functionality for choosing from different IMAP accounts still needs to be implemented."
            messageDialog.open()
        } else {
            syncToImapProgressDialog.close()
            messageDialog.title = "Unexpected Error"
            messageDialog.message = "Querying for IMAP accounts returned an unexpected value."
            messageDialog.open()
        }
    }

    function prepareImapFolder() {
        syncToImapProgressDialog.currentValue++

        if (! imapStorage.folderExists(imapAccountId, imapFolderName)) {
            console.log("Creating folder...")
            imapStorage.createFolder(imapAccountId, imapFolderName)
        } else {
            processImapFolder()
        }
    }

    function processImapFolder() {
        console.log("Processing content of IMAP folder...")
        syncToImapProgressDialog.currentValue++

        if (! imapStorage.folderExists(imapAccountId, imapFolderName)) {
            console.log("Error: IMAP folder does not exist!")
            return
        }

        imapStorage.retrieveMessageList(imapAccountId, imapFolderName)
    }

    function findAndRetrieveMessages() {
        console.log("Processing messages...")
        syncToImapProgressDialog.currentValue++

        var messageIds = imapStorage.queryMessages(imapAccountId, imapFolderName, imapMessageSubject)
        if (messageIds.length === 0) {
            console.log("No message found. Performing initital upload.")
            imapStorage.addMessage(imapAccountId, imapFolderName, imapMessageSubject, "to-do-o/default.xml")
            syncToImapProgressDialog.close()
            messageDialog.title = "Success"
            messageDialog.message = "Successfully performed initial sync."
            messageDialog.open()
        } else if (messageIds.length === 1) {
            console.log("Message found.")
            imapMessageId = messageIds[0]
            console.log("Message id is: " + imapMessageId)
            imapStorage.retrieveMessage(imapMessageId)
        } else {
            console.log("Error: Multiple messages found.")
        }
    }

    function processMessage() {
        console.log("Processing message...")
        syncToImapProgressDialog.currentValue++

        var attachmentLocations = imapStorage.getAttachmentLocations(imapMessageId)
        console.log("Found the following attachment locations: " + attachmentLocations)

        imapSyncFile = imapStorage.writeAttachmentTo(imapMessageId, attachmentLocations[0], "to-do-o")
        console.log("Wrote attachment to: " + imapSyncFile)

        if (rootElementModel.rowCount() === 0) {
            console.log("Initial sync, reloading storage...")
            fileHelper.rm(fileHelper.home() + "/to-do-o/default.xml")
            imapStorage.writeAttachmentTo(imapMessageId, attachmentLocations[0], "to-do-o")
            storage.open()
            syncToImapProgressDialog.close()
            messageDialog.title = "Success"
            messageDialog.message = "Successfully performed initial sync."
            messageDialog.open()
            return
        }

        merger.merge(imapSyncFile)
        storage.open()
        fileHelper.rm(imapSyncFile)

        imapStorage.updateMessageAttachment(imapMessageId, "to-do-o/default.xml")
    }

    ImapStorage {
        id: imapStorage

        onFolderCreated: processImapFolder()
        onFolderListRetrieved: prepareImapFolder()
        onMessageListRetrieved: findAndRetrieveMessages()
        onMessageRetrieved: processMessage()

        onMessageUpdated: {
            syncToImapProgressDialog.close()
            messageDialog.title = "Success"
            messageDialog.message = "Sync was successful."
            messageDialog.open()
        }

        onError: {
            syncToImapProgressDialog.close()
            messageDialog.title = "Error"
            messageDialog.message = "Sync failed: \"" + errorString + "\" Code: " + errorCode + " Action: " + currentAction
            messageDialog.open()
        }
    }

    ProgressDialog {
        id: syncToImapProgressDialog
        parent: syncToImapItem.parent

        title: "Syncing..."
        message: "Sync to IMAP in progess"

        maxValue: 5
        currentValue: 0
    }

    MessageDialog {
        id: messageDialog
        parent: syncToImapItem.parent
    }
}