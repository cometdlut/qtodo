/*
 *  Copyright 2012, 2013 Ruediger Gad
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
import "../common"

Rectangle {
    id: main

    anchors.fill: parent
    color: "white"

    Rectangle {
        anchors {top: parent.top; left: parent.left; right: parent.right; bottom: toolBarItem.top}
        color: "lightgoldenrodyellow"

        Header {
            id: header

            radius: parent.radius
            textColor: applicationWindow.windowFocus ? "white" : "black"

            /*
             * Thanks to alexisdm
             * http://stackoverflow.com/questions/10203260/moving-the-window-on-holding-qml-mousearea
             * for the hint on how to move the application window via QML
             */
            MouseArea {
                anchors.fill: parent
                property variant previousPosition

                onPressed: {
                    previousPosition = Qt.point(mouseX, mouseY)
                }

                onPositionChanged: {
                    if (pressedButtons == Qt.LeftButton) {
                        var dx = mouseX - previousPosition.x
                        var dy = mouseY - previousPosition.y
                        applicationWindow.pos = Qt.point(applicationWindow.pos.x + dx,
                                                    applicationWindow.pos.y + dy)
                    }
                }
            }
        }

        MainRectangle {
            id: mainRectangle
            anchors{left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom}
            focus: true

            Component.onCompleted: {
                treeView.fontPixelSize = 20
            }

            Keys.onDownPressed:{
                if (mainRectangle.treeView.currentNodeListView.currentIndex < (mainRectangle.treeView.currentModel.count - 1)) {
                    mainRectangle.treeView.currentNodeListView.currentIndex++
                    mainRectangle.treeView.expandTree()
                }
            }
            Keys.onUpPressed: {
                if (mainRectangle.treeView.currentNodeListView.currentIndex > 0) {
                    mainRectangle.treeView.currentNodeListView.currentIndex--
                    mainRectangle.treeView.expandTree()
                }
            }
            Keys.onLeftPressed: mainRectangle.treeView.currentLevel--
            Keys.onRightPressed: {
                mainRectangle.treeView.currentLevel++
                mainRectangle.treeView.expandTree()
            }
            Keys.onSpacePressed: {
                mainRectangle.treeView.toggleDone()
            }
            Keys.onEnterPressed: mainRectangle.editCurrentItem()
            Keys.onReturnPressed: mainRectangle.editCurrentItem()
            Keys.onPressed: {
                switch (event.key) {
                case Qt.Key_C:
                    if (event.modifiers & Qt.ControlModifier) {
                        mainRectangle.confirmCleanDoneDialog.open()
                    }
                    break
                case Qt.Key_D:
                    mainRectangle.confirmDeleteDialog.open()
                    break
                case Qt.Key_H:
                    mainRectangle.treeView.currentLevel--
                    break
                case Qt.Key_J:
                    if (mainRectangle.treeView.currentNodeListView.currentIndex < (mainRectangle.treeView.currentModel.count - 1)) {
                        mainRectangle.treeView.currentNodeListView.currentIndex++
                        mainRectangle.treeView.expandTree()
                    }
                    break
                case Qt.Key_K:
                    if (mainRectangle.treeView.currentNodeListView.currentIndex > 0) {
                        mainRectangle.treeView.currentNodeListView.currentIndex--
                        mainRectangle.treeView.expandTree()
                    }
                    break
                case Qt.Key_L:
                    mainRectangle.treeView.currentLevel++
                    mainRectangle.treeView.expandTree()
                    break
                case Qt.Key_S:
                    if (event.modifiers & Qt.ControlModifier) {
                        if (event.modifiers & Qt.ShiftModifier) {
                            mainRectangle.confirmSyncSketchesToImapDialog.open()
                        } else {
                            mainRectangle.confirmSyncToImapDialog.open()
                        }
                    }
                    break
                case Qt.Key_Plus:
                case Qt.Key_I:
                    mainRectangle.addItem()
                    break
                }
            }
        }
    }

    Rectangle {
        id: toolBarItem
        anchors {left: parent.left; right: parent.right; bottom: parent.bottom}
        height: commonTools.height

        color: "lightgray"

        QToDoToolBar {
            id: commonTools
        }
    }

    Menu {
        id: mainMenu

        CommonButton{
            id: cleanDone
            anchors.bottom: syncToImap.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Clean Done"
            onClicked: {
                mainRectangle.confirmCleanDoneDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncToImap
            anchors.bottom: syncSketchesToImap.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Sync to IMAP"
            onClicked: {
                mainRectangle.confirmSyncToImapDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncSketchesToImap
            anchors.bottom: about.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Sync Sketches to IMAP"
            onClicked: {
                mainRectangle.confirmSyncSketchesToImapDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: about
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "About"
            onClicked: {
                mainRectangle.aboutDialog.open()
                mainMenu.close()
            }
        }
    }

    Menu {
        id: contextMenu

        CommonButton{
            id: editItem
            anchors.bottom: deleteItem.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Edit"
            onClicked: {
                mainRectangle.editCurrentItem()
                contextMenu.close()
            }
        }

        CommonButton{
            id: deleteItem
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Delete"
            onClicked: {
                mainRectangle.deleteCurrentItem()
                contextMenu.close()
            }
        }
    }

    EditToDoSheet {
        id: editToDoItem

        onClosed: {
            mainRectangle.focus = true
        }
    }

    EditSketchSheet {
        id: editSketchItem
    }
}