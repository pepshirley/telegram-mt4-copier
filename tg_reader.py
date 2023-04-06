import os
import sys
import time
from threading import Thread
from datetime import datetime, timedelta
from queue import Queue
import asyncio
import os
from twilio.rest import Client
import socket

import cv2
import pytesseract
from PIL import Image
import numpy as np



from telethon import TelegramClient, events, utils
from PyQt5 import QtCore, QtGui, QtWidgets

pytesseract.pytesseract.tesseract_cmd = 'tesseract\\tesseract.exe'

assets = dict()

binaryToken = ''

parentDirectory = os.getcwd()

account_sid = 'AC19e6ae82c2b4e3e11d87af1113a07fe6'
auth_token = '8fc0e06400af94efe26e56d4f34a4e3d'
smsClient = Client(account_sid, auth_token)

LastTradeInfo = ''

currentList = list()

channel_list = list()

allowed_chats = list()

lastWarning = ''

channelSettings = list()

IDs = dict()

Messages = dict()

inputValues = dict()

IsUISetup = False

#UI CLASS
class Ui_MainWindow(object):
    def setupUi(self, MainWindow, queue_in, queue_out):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(1478, 834)
        MainWindow.setStyleSheet("font-family:Helvetica;background-color:#022859;")
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.terminalButton = QtWidgets.QPushButton(self.centralwidget)
        self.terminalButton.setGeometry(QtCore.QRect(180, 140, 111, 31))
        self.terminalButton.setStyleSheet("font-family:Helvetica;text-align:center;color:Black;background-color:#08428C;border-radius:15px;color:White;font-size:12px")
        self.terminalButton.setObjectName("terminalButton")
        self.terminalList = QtWidgets.QListWidget(self.centralwidget)
        self.terminalList.setGeometry(QtCore.QRect(100, 210, 281, 131))
        self.terminalList.setStyleSheet("font-family:Helvetica;padding:10px;text-align:center;color:White;background-color:#081526;border-radius:15px")
        self.terminalList.setObjectName("terminalList")
        self.config_label = QtWidgets.QLabel(self.centralwidget)
        self.config_label.setGeometry(QtCore.QRect(100, 60, 281, 20))
        self.config_label.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.config_label.setObjectName("config_label")
        self.terminalEdit = QtWidgets.QLineEdit(self.centralwidget)
        self.terminalEdit.setGeometry(QtCore.QRect(100, 90, 281, 41))
        self.terminalEdit.setStyleSheet("font-family:Helvetica;padding:10px;text-align:center;color:White;background-color:#081526;border-radius:15px")
        self.terminalEdit.setObjectName("terminalEdit")
        self.checkBox = QtWidgets.QCheckBox(self.centralwidget)
        self.checkBox.setGeometry(QtCore.QRect(1000, 670, 181, 41))
        self.checkBox.setStyleSheet("font-family:Helvetica;")
        self.checkBox.setObjectName("checkBox")
        self.terminal_label = QtWidgets.QLabel(self.centralwidget)
        self.terminal_label.setGeometry(QtCore.QRect(100, 180, 281, 20))
        self.terminal_label.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminal_label.setObjectName("terminal_label")
        self.chatSelect = QtWidgets.QComboBox(self.centralwidget)
        self.chatSelect.setGeometry(QtCore.QRect(100, 390, 281, 41))
        self.chatSelect.setStyleSheet("font-family:Helvetica;padding:10px;text-align:center;color:White;background-color:#081526;border-radius:15px")
        self.chatSelect.setObjectName("chatSelect")
        self.config_channels = QtWidgets.QLabel(self.centralwidget)
        self.config_channels.setGeometry(QtCore.QRect(100, 360, 281, 20))
        self.config_channels.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.config_channels.setObjectName("config_channels")
        self.chatList = QtWidgets.QListWidget(self.centralwidget)
        self.chatList.setGeometry(QtCore.QRect(100, 510, 281, 131))
        self.chatList.setStyleSheet("font-family:Helvetica;padding:10px;text-align:center;color:White;background-color:#081526;border-radius:15px")
        self.chatList.setObjectName("chatList")
        self.channel_label = QtWidgets.QLabel(self.centralwidget)
        self.channel_label.setGeometry(QtCore.QRect(100, 480, 281, 20))
        self.channel_label.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.channel_label.setObjectName("channel_label")
        self.config_label_6 = QtWidgets.QLabel(self.centralwidget)
        self.config_label_6.setGeometry(QtCore.QRect(430, 60, 281, 20))
        self.config_label_6.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.config_label_6.setObjectName("config_label_6")
        self.inputTab = QtWidgets.QTabWidget(self.centralwidget)
        self.inputTab.setGeometry(QtCore.QRect(430, 90, 371, 551))
        self.inputTab.setStyleSheet("font-family:Helvetica;padding:10px;text-align:center;color:#081526;background-color:#081526;border-radius:15px;border-color:#081526")
        self.inputTab.setElideMode(QtCore.Qt.ElideNone)
        self.inputTab.setUsesScrollButtons(True)
        self.inputTab.setObjectName("inputTab")
        self.tab = QtWidgets.QWidget()
        self.tab.setObjectName("tab")
        self.excSym = QtWidgets.QLineEdit(self.tab)
        self.excSym.setGeometry(QtCore.QRect(40, 10, 271, 41))
        self.excSym.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.excSym.setObjectName("excSym")
        self.incSym = QtWidgets.QLineEdit(self.tab)
        self.incSym.setGeometry(QtCore.QRect(40, 60, 271, 41))
        self.incSym.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.incSym.setText("")
        self.incSym.setObjectName("incSym")
        self.brokerSym = QtWidgets.QLineEdit(self.tab)
        self.brokerSym.setGeometry(QtCore.QRect(40, 110, 271, 41))
        self.brokerSym.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.brokerSym.setText("")
        self.brokerSym.setObjectName("brokerSym")
        self.specialSym = QtWidgets.QLineEdit(self.tab)
        self.specialSym.setGeometry(QtCore.QRect(40, 160, 271, 41))
        self.specialSym.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.specialSym.setText("")
        self.specialSym.setObjectName("specialSym")
        self.indicesList = QtWidgets.QLineEdit(self.tab)
        self.indicesList.setGeometry(QtCore.QRect(40, 210, 271, 41))
        self.indicesList.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.indicesList.setText("")
        self.indicesList.setObjectName("indicesList")
        self.commList = QtWidgets.QLineEdit(self.tab)
        self.commList.setGeometry(QtCore.QRect(40, 260, 271, 41))
        self.commList.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.commList.setText("")
        self.commList.setObjectName("commList")
        self.cryptoList = QtWidgets.QLineEdit(self.tab)
        self.cryptoList.setGeometry(QtCore.QRect(40, 310, 271, 41))
        self.cryptoList.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.cryptoList.setText("")
        self.cryptoList.setObjectName("cryptoList")
        self.inputTab.addTab(self.tab, "")
        self.tab_2 = QtWidgets.QWidget()
        self.tab_2.setObjectName("tab_2")
        self.listWidget = QtWidgets.QListWidget(self.tab_2)
        self.listWidget.setGeometry(QtCore.QRect(10, 10, 271, 481))
        self.listWidget.setObjectName("listWidget")
        self.lotPerTPcrypto = QtWidgets.QLineEdit(self.tab_2)
        self.lotPerTPcrypto.setGeometry(QtCore.QRect(40, 360, 271, 41))
        self.lotPerTPcrypto.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.lotPerTPcrypto.setObjectName("lotPerTPcrypto")
        self.lotPerTPindices = QtWidgets.QLineEdit(self.tab_2)
        self.lotPerTPindices.setGeometry(QtCore.QRect(40, 310, 271, 41))
        self.lotPerTPindices.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.lotPerTPindices.setObjectName("lotPerTPindices")
        self.lotValue = QtWidgets.QLineEdit(self.tab_2)
        self.lotValue.setGeometry(QtCore.QRect(40, 110, 271, 41))
        self.lotValue.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.lotValue.setObjectName("lotValue")
        self.riskSource = QtWidgets.QComboBox(self.tab_2)
        self.riskSource.setGeometry(QtCore.QRect(40, 160, 271, 41))
        self.riskSource.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.riskSource.setObjectName("riskSource")
        self.riskSource.addItem("")
        self.riskSource.addItem("")
        self.lotPerTPCurr = QtWidgets.QLineEdit(self.tab_2)
        self.lotPerTPCurr.setGeometry(QtCore.QRect(40, 260, 271, 41))
        self.lotPerTPCurr.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.lotPerTPCurr.setObjectName("lotPerTPCurr")
        self.riskMode = QtWidgets.QComboBox(self.tab_2)
        self.riskMode.setGeometry(QtCore.QRect(40, 60, 271, 41))
        self.riskMode.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.riskMode.setObjectName("riskMode")
        self.riskMode.addItem("")
        self.riskMode.addItem("")
        self.riskPerc = QtWidgets.QLineEdit(self.tab_2)
        self.riskPerc.setGeometry(QtCore.QRect(40, 210, 271, 41))
        self.riskPerc.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.riskPerc.setObjectName("riskPerc")
        self.lotPerSymbol = QtWidgets.QLineEdit(self.tab_2)
        self.lotPerSymbol.setGeometry(QtCore.QRect(40, 10, 271, 41))
        self.lotPerSymbol.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.lotPerSymbol.setObjectName("lotPerSymbol")
        self.maxDD = QtWidgets.QLineEdit(self.tab_2)
        self.maxDD.setGeometry(QtCore.QRect(40, 410, 271, 41))
        self.maxDD.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.maxDD.setObjectName("maxDD")
        self.inputTab.addTab(self.tab_2, "")
        self.tab_3 = QtWidgets.QWidget()
        self.tab_3.setObjectName("tab_3")
        self.defaultTPcurrencies = QtWidgets.QLineEdit(self.tab_3)
        self.defaultTPcurrencies.setGeometry(QtCore.QRect(40, 170, 271, 41))
        self.defaultTPcurrencies.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.defaultTPcurrencies.setObjectName("defaultTPcurrencies")
        self.addSpread = QtWidgets.QComboBox(self.tab_3)
        self.addSpread.setGeometry(QtCore.QRect(40, 40, 271, 41))
        self.addSpread.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.addSpread.setObjectName("addSpread")
        self.addSpread.addItem("")
        self.addSpread.addItem("")
        self.addSpreadLabel = QtWidgets.QLabel(self.tab_3)
        self.addSpreadLabel.setGeometry(QtCore.QRect(40, 0, 181, 41))
        self.addSpreadLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.addSpreadLabel.setObjectName("addSpreadLabel")
        self.addSpreadTPLabel = QtWidgets.QLabel(self.tab_3)
        self.addSpreadTPLabel.setGeometry(QtCore.QRect(40, 90, 181, 31))
        self.addSpreadTPLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.addSpreadTPLabel.setObjectName("addSpreadTPLabel")
        self.addSpreadTP = QtWidgets.QComboBox(self.tab_3)
        self.addSpreadTP.setGeometry(QtCore.QRect(40, 120, 271, 41))
        self.addSpreadTP.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.addSpreadTP.setObjectName("addSpreadTP")
        self.addSpreadTP.addItem("")
        self.addSpreadTP.addItem("")
        self.defaultSLcurrencies = QtWidgets.QLineEdit(self.tab_3)
        self.defaultSLcurrencies.setGeometry(QtCore.QRect(40, 220, 271, 41))
        self.defaultSLcurrencies.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.defaultSLcurrencies.setObjectName("defaultSLcurrencies")
        self.defaultTPothers = QtWidgets.QLineEdit(self.tab_3)
        self.defaultTPothers.setGeometry(QtCore.QRect(40, 270, 271, 41))
        self.defaultTPothers.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.defaultTPothers.setObjectName("defaultTPothers")
        self.defaultSLothers = QtWidgets.QLineEdit(self.tab_3)
        self.defaultSLothers.setGeometry(QtCore.QRect(40, 320, 271, 41))
        self.defaultSLothers.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.defaultSLothers.setObjectName("defaultSLothers")
        self.rejectSL = QtWidgets.QComboBox(self.tab_3)
        self.rejectSL.setGeometry(QtCore.QRect(40, 400, 271, 41))
        self.rejectSL.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.rejectSL.setObjectName("rejectSL")
        self.rejectSL.addItem("")
        self.rejectSL.addItem("")
        self.rejectSLLabel = QtWidgets.QLabel(self.tab_3)
        self.rejectSLLabel.setGeometry(QtCore.QRect(40, 370, 181, 31))
        self.rejectSLLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.rejectSLLabel.setObjectName("rejectSLLabel")
        self.inputTab.addTab(self.tab_3, "")
        self.tab_7 = QtWidgets.QWidget()
        self.tab_7.setObjectName("tab_7")
        self.slMode = QtWidgets.QComboBox(self.tab_7)
        self.slMode.setGeometry(QtCore.QRect(40, 30, 271, 41))
        self.slMode.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.slMode.setObjectName("slMode")
        self.slMode.addItem("")
        self.slMode.addItem("")
        self.slModeLabel = QtWidgets.QLabel(self.tab_7)
        self.slModeLabel.setGeometry(QtCore.QRect(40, 0, 181, 31))
        self.slModeLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.slModeLabel.setObjectName("slModeLabel")
        self.tpModeLabel = QtWidgets.QLabel(self.tab_7)
        self.tpModeLabel.setGeometry(QtCore.QRect(40, 70, 181, 31))
        self.tpModeLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.tpModeLabel.setObjectName("tpModeLabel")
        self.tpMode = QtWidgets.QComboBox(self.tab_7)
        self.tpMode.setGeometry(QtCore.QRect(40, 100, 271, 41))
        self.tpMode.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.tpMode.setObjectName("tpMode")
        self.tpMode.addItem("")
        self.tpMode.addItem("")
        self.multiTP = QtWidgets.QComboBox(self.tab_7)
        self.multiTP.setGeometry(QtCore.QRect(40, 180, 271, 41))
        self.multiTP.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.multiTP.setObjectName("multiTP")
        self.multiTP.addItem("")
        self.multiTP.addItem("")
        self.multiTPlabel = QtWidgets.QLabel(self.tab_7)
        self.multiTPlabel.setGeometry(QtCore.QRect(40, 150, 181, 31))
        self.multiTPlabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.multiTPlabel.setObjectName("multiTPlabel")
        self.tradesPerTP = QtWidgets.QLineEdit(self.tab_7)
        self.tradesPerTP.setGeometry(QtCore.QRect(40, 230, 271, 41))
        self.tradesPerTP.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.tradesPerTP.setObjectName("tradesPerTP")
        self.divLot = QtWidgets.QComboBox(self.tab_7)
        self.divLot.setGeometry(QtCore.QRect(40, 310, 271, 41))
        self.divLot.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.divLot.setObjectName("divLot")
        self.divLot.addItem("")
        self.divLot.addItem("")
        self.divLotLabel = QtWidgets.QLabel(self.tab_7)
        self.divLotLabel.setGeometry(QtCore.QRect(40, 280, 181, 31))
        self.divLotLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.divLotLabel.setObjectName("divLotLabel")
        self.moveSL = QtWidgets.QComboBox(self.tab_7)
        self.moveSL.setGeometry(QtCore.QRect(40, 390, 271, 41))
        self.moveSL.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.moveSL.setObjectName("moveSL")
        self.moveSL.addItem("")
        self.moveSL.addItem("")
        self.moveSLLabel = QtWidgets.QLabel(self.tab_7)
        self.moveSLLabel.setGeometry(QtCore.QRect(40, 360, 181, 31))
        self.moveSLLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.moveSLLabel.setObjectName("moveSLLabel")
        self.dynamicSL = QtWidgets.QLineEdit(self.tab_7)
        self.dynamicSL.setGeometry(QtCore.QRect(40, 440, 271, 41))
        self.dynamicSL.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.dynamicSL.setObjectName("dynamicSL")
        self.inputTab.addTab(self.tab_7, "")
        self.tab_8 = QtWidgets.QWidget()
        self.tab_8.setObjectName("tab_8")
        self.execLimitLabel = QtWidgets.QLabel(self.tab_8)
        self.execLimitLabel.setGeometry(QtCore.QRect(40, 0, 181, 31))
        self.execLimitLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.execLimitLabel.setObjectName("execLimitLabel")
        self.execLimit = QtWidgets.QComboBox(self.tab_8)
        self.execLimit.setGeometry(QtCore.QRect(40, 30, 271, 41))
        self.execLimit.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.execLimit.setObjectName("execLimit")
        self.execLimit.addItem("")
        self.execLimit.addItem("")
        self.limitExpiry = QtWidgets.QLineEdit(self.tab_8)
        self.limitExpiry.setGeometry(QtCore.QRect(40, 80, 271, 41))
        self.limitExpiry.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.limitExpiry.setObjectName("limitExpiry")
        self.numTrades = QtWidgets.QLineEdit(self.tab_8)
        self.numTrades.setGeometry(QtCore.QRect(40, 130, 271, 41))
        self.numTrades.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.numTrades.setObjectName("numTrades")
        self.maxOrders = QtWidgets.QLineEdit(self.tab_8)
        self.maxOrders.setGeometry(QtCore.QRect(40, 180, 271, 41))
        self.maxOrders.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.maxOrders.setObjectName("maxOrders")
        self.maxOrderPerSymbol = QtWidgets.QLineEdit(self.tab_8)
        self.maxOrderPerSymbol.setGeometry(QtCore.QRect(40, 230, 271, 41))
        self.maxOrderPerSymbol.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.maxOrderPerSymbol.setObjectName("maxOrderPerSymbol")
        self.partialClosePerc = QtWidgets.QLineEdit(self.tab_8)
        self.partialClosePerc.setGeometry(QtCore.QRect(40, 280, 271, 41))
        self.partialClosePerc.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.partialClosePerc.setObjectName("partialClosePerc")
        self.beAfter = QtWidgets.QLineEdit(self.tab_8)
        self.beAfter.setGeometry(QtCore.QRect(40, 330, 271, 41))
        self.beAfter.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.beAfter.setObjectName("beAfter")
        self.closeTradeAfter = QtWidgets.QLineEdit(self.tab_8)
        self.closeTradeAfter.setGeometry(QtCore.QRect(40, 380, 271, 41))
        self.closeTradeAfter.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.closeTradeAfter.setObjectName("closeTradeAfter")
        self.showSender = QtWidgets.QComboBox(self.tab_8)
        self.showSender.setGeometry(QtCore.QRect(40, 450, 271, 41))
        self.showSender.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.showSender.setObjectName("showSender")
        self.showSender.addItem("")
        self.showSender.addItem("")
        self.showSenderLabel = QtWidgets.QLabel(self.tab_8)
        self.showSenderLabel.setGeometry(QtCore.QRect(40, 420, 181, 31))
        self.showSenderLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.showSenderLabel.setObjectName("showSenderLabel")
        self.inputTab.addTab(self.tab_8, "")
        self.tab_9 = QtWidgets.QWidget()
        self.tab_9.setObjectName("tab_9")
        self.shutdown = QtWidgets.QComboBox(self.tab_9)
        self.shutdown.setGeometry(QtCore.QRect(40, 30, 271, 41))
        self.shutdown.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.shutdown.setObjectName("shutdown")
        self.shutdown.addItem("")
        self.shutdown.addItem("")
        self.shutdownLabel = QtWidgets.QLabel(self.tab_9)
        self.shutdownLabel.setGeometry(QtCore.QRect(40, 0, 181, 31))
        self.shutdownLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.shutdownLabel.setObjectName("shutdownLabel")
        self.EACloseDay = QtWidgets.QComboBox(self.tab_9)
        self.EACloseDay.setGeometry(QtCore.QRect(40, 110, 271, 41))
        self.EACloseDay.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.EACloseDay.setObjectName("EACloseDay")
        self.EACloseDay.addItem("")
        self.EACloseDay.addItem("")
        self.EACloseDay.addItem("")
        self.EACloseDay.addItem("")
        self.EACloseDay.addItem("")
        self.EACloseDay.addItem("")
        self.EACloseDay.addItem("")
        self.EACloseDayLabel = QtWidgets.QLabel(self.tab_9)
        self.EACloseDayLabel.setGeometry(QtCore.QRect(40, 80, 181, 31))
        self.EACloseDayLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.EACloseDayLabel.setObjectName("EACloseDayLabel")
        self.EACloseTime = QtWidgets.QLineEdit(self.tab_9)
        self.EACloseTime.setGeometry(QtCore.QRect(40, 160, 271, 41))
        self.EACloseTime.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.EACloseTime.setObjectName("EACloseTime")
        self.EARestartDay = QtWidgets.QComboBox(self.tab_9)
        self.EARestartDay.setGeometry(QtCore.QRect(40, 240, 271, 41))
        self.EARestartDay.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.EARestartDay.setObjectName("EARestartDay")
        self.EARestartDay.addItem("")
        self.EARestartDay.addItem("")
        self.EARestartDay.addItem("")
        self.EARestartDay.addItem("")
        self.EARestartDay.addItem("")
        self.EARestartDay.addItem("")
        self.EARestartDay.addItem("")
        self.EARestartDayLabel = QtWidgets.QLabel(self.tab_9)
        self.EARestartDayLabel.setGeometry(QtCore.QRect(40, 210, 181, 31))
        self.EARestartDayLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.EARestartDayLabel.setObjectName("EARestartDayLabel")
        self.EARestartTime = QtWidgets.QLineEdit(self.tab_9)
        self.EARestartTime.setGeometry(QtCore.QRect(40, 290, 271, 41))
        self.EARestartTime.setStyleSheet("font-family:Helvetica;background-color:#022859;color:White;border-radius:20px")
        self.EARestartTime.setObjectName("EARestartTime")
        self.inputTab.addTab(self.tab_9, "")
        self.saveButton = QtWidgets.QPushButton(self.centralwidget)
        self.saveButton.setGeometry(QtCore.QRect(490, 670, 111, 31))
        self.saveButton.setStyleSheet("font-family:Helvetica;text-align:center;color:Black;background-color:#08428C;border-radius:15px;color:White;font-size:12px")
        self.saveButton.setObjectName("saveButton")
        self.loadButton = QtWidgets.QPushButton(self.centralwidget)
        self.loadButton.setGeometry(QtCore.QRect(610, 670, 111, 31))
        self.loadButton.setStyleSheet("font-family:Helvetica;text-align:center;color:Black;background-color:#081526;border-radius:15px;color:White;font-size:12px")
        self.loadButton.setObjectName("loadButton")
        self.authWarning = QtWidgets.QLabel(self.centralwidget)
        self.authWarning.setGeometry(QtCore.QRect(290, 20, 551, 41))
        self.authWarning.setStyleSheet("font-family:Helvetica;font:bold;color:#8B0000")
        self.authWarning.setText("")
        self.authWarning.setAlignment(QtCore.Qt.AlignHCenter|QtCore.Qt.AlignTop)
        self.authWarning.setObjectName("authWarning")
        self.chatButton = QtWidgets.QPushButton(self.centralwidget)
        self.chatButton.setGeometry(QtCore.QRect(180, 440, 111, 31))
        self.chatButton.setStyleSheet("font-family:Helvetica;text-align:center;color:Black;background-color:#08428C;border-radius:15px;color:White;font-size:12px")
        self.chatButton.setObjectName("chatButton")
        self.tabWidget = QtWidgets.QTabWidget(self.centralwidget)
        self.tabWidget.setGeometry(QtCore.QRect(840, 70, 421, 571))
        self.tabWidget.setStyleSheet("font-family:Helvetica;text-align:center;color:Black;background-color:#08428C;border-radius:15px;color:#08428C;font-size:12px")
        self.tabWidget.setObjectName("tabWidget")
        self.tab_5 = QtWidgets.QWidget()
        self.tab_5.setObjectName("tab_5")
        self.frame_2 = QtWidgets.QFrame(self.tab_5)
        self.frame_2.setGeometry(QtCore.QRect(30, 140, 361, 71))
        self.frame_2.setStyleSheet("font-family:Helvetica;;background-color:#022859;border-radius:15px")
        self.frame_2.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_2.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_2.setObjectName("frame_2")
        self.terminalName_2 = QtWidgets.QLabel(self.frame_2)
        self.terminalName_2.setGeometry(QtCore.QRect(20, 10, 160, 21))
        self.terminalName_2.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminalName_2.setText("")
        self.terminalName_2.setObjectName("terminalName_2")
        self.terminalDGLabel_2 = QtWidgets.QLabel(self.frame_2)
        self.terminalDGLabel_2.setGeometry(QtCore.QRect(180, 10, 80, 21))
        self.terminalDGLabel_2.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalDGLabel_2.setObjectName("terminalDGLabel_2")
        self.terminalTGLabel_2 = QtWidgets.QLabel(self.frame_2)
        self.terminalTGLabel_2.setGeometry(QtCore.QRect(270, 10, 80, 21))
        self.terminalTGLabel_2.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalTGLabel_2.setObjectName("terminalTGLabel_2")
        self.terminalDG_2 = QtWidgets.QLabel(self.frame_2)
        self.terminalDG_2.setGeometry(QtCore.QRect(190, 30, 60, 21))
        self.terminalDG_2.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalDG_2.setText("")
        self.terminalDG_2.setObjectName("terminalDG_2")
        self.terminalTG_2 = QtWidgets.QLabel(self.frame_2)
        self.terminalTG_2.setGeometry(QtCore.QRect(280, 30, 60, 21))
        self.terminalTG_2.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalTG_2.setText("")
        self.terminalTG_2.setObjectName("terminalTG_2")
        self.terminalUpdateTime_2 = QtWidgets.QLabel(self.frame_2)
        self.terminalUpdateTime_2.setGeometry(QtCore.QRect(20, 40, 151, 20))
        self.terminalUpdateTime_2.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalUpdateTime_2.setObjectName("terminalUpdateTime_2")
        self.frame_3 = QtWidgets.QFrame(self.tab_5)
        self.frame_3.setGeometry(QtCore.QRect(30, 230, 361, 71))
        self.frame_3.setStyleSheet("font-family:Helvetica;;background-color:#022859;border-radius:15px")
        self.frame_3.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_3.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_3.setObjectName("frame_3")
        self.terminalName_3 = QtWidgets.QLabel(self.frame_3)
        self.terminalName_3.setGeometry(QtCore.QRect(20, 10, 160, 21))
        self.terminalName_3.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminalName_3.setText("")
        self.terminalName_3.setObjectName("terminalName_3")
        self.terminalDGLabel_3 = QtWidgets.QLabel(self.frame_3)
        self.terminalDGLabel_3.setGeometry(QtCore.QRect(180, 10, 80, 21))
        self.terminalDGLabel_3.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalDGLabel_3.setObjectName("terminalDGLabel_3")
        self.terminalTGLabel_3 = QtWidgets.QLabel(self.frame_3)
        self.terminalTGLabel_3.setGeometry(QtCore.QRect(270, 10, 80, 21))
        self.terminalTGLabel_3.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalTGLabel_3.setObjectName("terminalTGLabel_3")
        self.terminalDG_3 = QtWidgets.QLabel(self.frame_3)
        self.terminalDG_3.setGeometry(QtCore.QRect(190, 30, 60, 21))
        self.terminalDG_3.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalDG_3.setText("")
        self.terminalDG_3.setObjectName("terminalDG_3")
        self.terminalTG_3 = QtWidgets.QLabel(self.frame_3)
        self.terminalTG_3.setGeometry(QtCore.QRect(280, 30, 60, 21))
        self.terminalTG_3.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalTG_3.setText("")
        self.terminalTG_3.setObjectName("terminalTG_3")
        self.terminalUpdateTime_3 = QtWidgets.QLabel(self.frame_3)
        self.terminalUpdateTime_3.setGeometry(QtCore.QRect(20, 40, 151, 20))
        self.terminalUpdateTime_3.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalUpdateTime_3.setObjectName("terminalUpdateTime_3")
        self.frame_4 = QtWidgets.QFrame(self.tab_5)
        self.frame_4.setGeometry(QtCore.QRect(30, 320, 361, 71))
        self.frame_4.setStyleSheet("font-family:Helvetica;;background-color:#022859;border-radius:15px")
        self.frame_4.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_4.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_4.setObjectName("frame_4")
        self.terminalName_4 = QtWidgets.QLabel(self.frame_4)
        self.terminalName_4.setGeometry(QtCore.QRect(20, 10, 160, 21))
        self.terminalName_4.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminalName_4.setText("")
        self.terminalName_4.setObjectName("terminalName_4")
        self.terminalDGLabel_4 = QtWidgets.QLabel(self.frame_4)
        self.terminalDGLabel_4.setGeometry(QtCore.QRect(180, 10, 80, 21))
        self.terminalDGLabel_4.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalDGLabel_4.setObjectName("terminalDGLabel_4")
        self.terminalTGLabel_4 = QtWidgets.QLabel(self.frame_4)
        self.terminalTGLabel_4.setGeometry(QtCore.QRect(270, 10, 80, 21))
        self.terminalTGLabel_4.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalTGLabel_4.setObjectName("terminalTGLabel_4")
        self.terminalDG_4 = QtWidgets.QLabel(self.frame_4)
        self.terminalDG_4.setGeometry(QtCore.QRect(190, 30, 60, 21))
        self.terminalDG_4.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalDG_4.setText("")
        self.terminalDG_4.setObjectName("terminalDG_4")
        self.terminalTG_4 = QtWidgets.QLabel(self.frame_4)
        self.terminalTG_4.setGeometry(QtCore.QRect(280, 30, 60, 21))
        self.terminalTG_4.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalTG_4.setText("")
        self.terminalTG_4.setObjectName("terminalTG_4")
        self.terminalUpdateTime_4 = QtWidgets.QLabel(self.frame_4)
        self.terminalUpdateTime_4.setGeometry(QtCore.QRect(20, 40, 151, 20))
        self.terminalUpdateTime_4.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalUpdateTime_4.setObjectName("terminalUpdateTime_4")
        self.frame_5 = QtWidgets.QFrame(self.tab_5)
        self.frame_5.setGeometry(QtCore.QRect(30, 410, 361, 71))
        self.frame_5.setStyleSheet("font-family:Helvetica;;background-color:#022859;border-radius:15px")
        self.frame_5.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_5.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_5.setObjectName("frame_5")
        self.terminalName_5 = QtWidgets.QLabel(self.frame_5)
        self.terminalName_5.setGeometry(QtCore.QRect(20, 10, 160, 21))
        self.terminalName_5.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminalName_5.setText("")
        self.terminalName_5.setObjectName("terminalName_5")
        self.terminalDGLabel_5 = QtWidgets.QLabel(self.frame_5)
        self.terminalDGLabel_5.setGeometry(QtCore.QRect(180, 10, 80, 21))
        self.terminalDGLabel_5.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalDGLabel_5.setObjectName("terminalDGLabel_5")
        self.terminalTGLabel_5 = QtWidgets.QLabel(self.frame_5)
        self.terminalTGLabel_5.setGeometry(QtCore.QRect(270, 10, 80, 21))
        self.terminalTGLabel_5.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalTGLabel_5.setObjectName("terminalTGLabel_5")
        self.terminalDG_5 = QtWidgets.QLabel(self.frame_5)
        self.terminalDG_5.setGeometry(QtCore.QRect(190, 30, 60, 21))
        self.terminalDG_5.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalDG_5.setText("")
        self.terminalDG_5.setObjectName("terminalDG_5")
        self.terminalTG_5 = QtWidgets.QLabel(self.frame_5)
        self.terminalTG_5.setGeometry(QtCore.QRect(280, 30, 60, 21))
        self.terminalTG_5.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalTG_5.setText("")
        self.terminalTG_5.setObjectName("terminalTG_5")
        self.terminalUpdateTime_5 = QtWidgets.QLabel(self.frame_5)
        self.terminalUpdateTime_5.setGeometry(QtCore.QRect(20, 40, 151, 20))
        self.terminalUpdateTime_5.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalUpdateTime_5.setObjectName("terminalUpdateTime_5")
        self.frame = QtWidgets.QFrame(self.tab_5)
        self.frame.setGeometry(QtCore.QRect(30, 50, 361, 71))
        self.frame.setStyleSheet("font-family:Helvetica;;background-color:#022859;border-radius:15px")
        self.frame.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame.setObjectName("frame")
        self.terminalName = QtWidgets.QLabel(self.frame)
        self.terminalName.setGeometry(QtCore.QRect(20, 10, 160, 21))
        self.terminalName.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminalName.setText("")
        self.terminalName.setObjectName("terminalName")
        self.terminalDGLabel = QtWidgets.QLabel(self.frame)
        self.terminalDGLabel.setGeometry(QtCore.QRect(180, 10, 80, 21))
        self.terminalDGLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalDGLabel.setObjectName("terminalDGLabel")
        self.terminalTGLabel = QtWidgets.QLabel(self.frame)
        self.terminalTGLabel.setGeometry(QtCore.QRect(270, 10, 80, 21))
        self.terminalTGLabel.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalTGLabel.setObjectName("terminalTGLabel")
        self.terminalDG = QtWidgets.QLabel(self.frame)
        self.terminalDG.setGeometry(QtCore.QRect(190, 30, 60, 21))
        self.terminalDG.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalDG.setText("")
        self.terminalDG.setObjectName("terminalDG")
        self.terminalTG = QtWidgets.QLabel(self.frame)
        self.terminalTG.setGeometry(QtCore.QRect(280, 30, 60, 21))
        self.terminalTG.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalTG.setText("")
        self.terminalTG.setObjectName("terminalTG")
        self.terminalUpdateTime = QtWidgets.QLabel(self.frame)
        self.terminalUpdateTime.setGeometry(QtCore.QRect(20, 40, 151, 20))
        self.terminalUpdateTime.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalUpdateTime.setObjectName("terminalUpdateTime")
        self.tabWidget.addTab(self.tab_5, "")
        self.tab_4 = QtWidgets.QWidget()
        self.tab_4.setObjectName("tab_4")
        self.frame_6 = QtWidgets.QFrame(self.tab_4)
        self.frame_6.setGeometry(QtCore.QRect(30, 50, 361, 71))
        self.frame_6.setStyleSheet("font-family:Helvetica;;background-color:#022859;border-radius:15px")
        self.frame_6.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_6.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_6.setObjectName("frame_6")
        self.terminalName_6 = QtWidgets.QLabel(self.frame_6)
        self.terminalName_6.setGeometry(QtCore.QRect(20, 10, 160, 21))
        self.terminalName_6.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminalName_6.setText("")
        self.terminalName_6.setObjectName("terminalName_6")
        self.terminalDGLabel_6 = QtWidgets.QLabel(self.frame_6)
        self.terminalDGLabel_6.setGeometry(QtCore.QRect(180, 10, 80, 21))
        self.terminalDGLabel_6.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalDGLabel_6.setObjectName("terminalDGLabel_6")
        self.terminalTGLabel_6 = QtWidgets.QLabel(self.frame_6)
        self.terminalTGLabel_6.setGeometry(QtCore.QRect(270, 10, 80, 21))
        self.terminalTGLabel_6.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalTGLabel_6.setObjectName("terminalTGLabel_6")
        self.terminalDG_6 = QtWidgets.QLabel(self.frame_6)
        self.terminalDG_6.setGeometry(QtCore.QRect(190, 30, 60, 21))
        self.terminalDG_6.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalDG_6.setText("")
        self.terminalDG_6.setObjectName("terminalDG_6")
        self.terminalTG_6 = QtWidgets.QLabel(self.frame_6)
        self.terminalTG_6.setGeometry(QtCore.QRect(280, 30, 60, 21))
        self.terminalTG_6.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalTG_6.setText("")
        self.terminalTG_6.setObjectName("terminalTG_6")
        self.terminalUpdateTime_6 = QtWidgets.QLabel(self.frame_6)
        self.terminalUpdateTime_6.setGeometry(QtCore.QRect(20, 40, 151, 20))
        self.terminalUpdateTime_6.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalUpdateTime_6.setObjectName("terminalUpdateTime_6")
        self.frame_7 = QtWidgets.QFrame(self.tab_4)
        self.frame_7.setGeometry(QtCore.QRect(30, 140, 361, 71))
        self.frame_7.setStyleSheet("font-family:Helvetica;;background-color:#022859;border-radius:15px")
        self.frame_7.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_7.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_7.setObjectName("frame_7")
        self.terminalName_7 = QtWidgets.QLabel(self.frame_7)
        self.terminalName_7.setGeometry(QtCore.QRect(20, 10, 160, 21))
        self.terminalName_7.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminalName_7.setText("")
        self.terminalName_7.setObjectName("terminalName_7")
        self.terminalDGLabel_7 = QtWidgets.QLabel(self.frame_7)
        self.terminalDGLabel_7.setGeometry(QtCore.QRect(180, 10, 80, 21))
        self.terminalDGLabel_7.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalDGLabel_7.setObjectName("terminalDGLabel_7")
        self.terminalTGLabel_7 = QtWidgets.QLabel(self.frame_7)
        self.terminalTGLabel_7.setGeometry(QtCore.QRect(270, 10, 80, 21))
        self.terminalTGLabel_7.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalTGLabel_7.setObjectName("terminalTGLabel_7")
        self.terminalDG_7 = QtWidgets.QLabel(self.frame_7)
        self.terminalDG_7.setGeometry(QtCore.QRect(190, 30, 60, 21))
        self.terminalDG_7.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalDG_7.setText("")
        self.terminalDG_7.setObjectName("terminalDG_7")
        self.terminalTG_7 = QtWidgets.QLabel(self.frame_7)
        self.terminalTG_7.setGeometry(QtCore.QRect(280, 30, 60, 21))
        self.terminalTG_7.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalTG_7.setText("")
        self.terminalTG_7.setObjectName("terminalTG_7")
        self.terminalUpdateTime_7 = QtWidgets.QLabel(self.frame_7)
        self.terminalUpdateTime_7.setGeometry(QtCore.QRect(20, 40, 151, 20))
        self.terminalUpdateTime_7.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalUpdateTime_7.setObjectName("terminalUpdateTime_7")
        self.frame_8 = QtWidgets.QFrame(self.tab_4)
        self.frame_8.setGeometry(QtCore.QRect(30, 230, 361, 71))
        self.frame_8.setStyleSheet("font-family:Helvetica;;background-color:#022859;border-radius:15px")
        self.frame_8.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_8.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_8.setObjectName("frame_8")
        self.terminalName_8 = QtWidgets.QLabel(self.frame_8)
        self.terminalName_8.setGeometry(QtCore.QRect(20, 10, 160, 21))
        self.terminalName_8.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminalName_8.setText("")
        self.terminalName_8.setObjectName("terminalName_8")
        self.terminalDGLabel_8 = QtWidgets.QLabel(self.frame_8)
        self.terminalDGLabel_8.setGeometry(QtCore.QRect(180, 10, 80, 21))
        self.terminalDGLabel_8.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalDGLabel_8.setObjectName("terminalDGLabel_8")
        self.terminalTGLabel_8 = QtWidgets.QLabel(self.frame_8)
        self.terminalTGLabel_8.setGeometry(QtCore.QRect(270, 10, 80, 21))
        self.terminalTGLabel_8.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalTGLabel_8.setObjectName("terminalTGLabel_8")
        self.terminalDG_8 = QtWidgets.QLabel(self.frame_8)
        self.terminalDG_8.setGeometry(QtCore.QRect(190, 30, 60, 21))
        self.terminalDG_8.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalDG_8.setText("")
        self.terminalDG_8.setObjectName("terminalDG_8")
        self.terminalTG_8 = QtWidgets.QLabel(self.frame_8)
        self.terminalTG_8.setGeometry(QtCore.QRect(280, 30, 60, 21))
        self.terminalTG_8.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalTG_8.setText("")
        self.terminalTG_8.setObjectName("terminalTG_8")
        self.terminalUpdateTime_8 = QtWidgets.QLabel(self.frame_8)
        self.terminalUpdateTime_8.setGeometry(QtCore.QRect(20, 40, 151, 20))
        self.terminalUpdateTime_8.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalUpdateTime_8.setObjectName("terminalUpdateTime_8")
        self.frame_9 = QtWidgets.QFrame(self.tab_4)
        self.frame_9.setGeometry(QtCore.QRect(30, 320, 361, 71))
        self.frame_9.setStyleSheet("font-family:Helvetica;;background-color:#022859;border-radius:15px")
        self.frame_9.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_9.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_9.setObjectName("frame_9")
        self.terminalName_9 = QtWidgets.QLabel(self.frame_9)
        self.terminalName_9.setGeometry(QtCore.QRect(20, 10, 160, 21))
        self.terminalName_9.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminalName_9.setText("")
        self.terminalName_9.setObjectName("terminalName_9")
        self.terminalDGLabel_9 = QtWidgets.QLabel(self.frame_9)
        self.terminalDGLabel_9.setGeometry(QtCore.QRect(180, 10, 80, 21))
        self.terminalDGLabel_9.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalDGLabel_9.setObjectName("terminalDGLabel_9")
        self.terminalTGLabel_9 = QtWidgets.QLabel(self.frame_9)
        self.terminalTGLabel_9.setGeometry(QtCore.QRect(270, 10, 80, 21))
        self.terminalTGLabel_9.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalTGLabel_9.setObjectName("terminalTGLabel_9")
        self.terminalDG_9 = QtWidgets.QLabel(self.frame_9)
        self.terminalDG_9.setGeometry(QtCore.QRect(190, 30, 60, 21))
        self.terminalDG_9.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalDG_9.setText("")
        self.terminalDG_9.setObjectName("terminalDG_9")
        self.terminalTG_9 = QtWidgets.QLabel(self.frame_9)
        self.terminalTG_9.setGeometry(QtCore.QRect(280, 30, 60, 21))
        self.terminalTG_9.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalTG_9.setText("")
        self.terminalTG_9.setObjectName("terminalTG_9")
        self.terminalUpdateTime_9 = QtWidgets.QLabel(self.frame_9)
        self.terminalUpdateTime_9.setGeometry(QtCore.QRect(20, 40, 151, 20))
        self.terminalUpdateTime_9.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalUpdateTime_9.setObjectName("terminalUpdateTime_9")
        self.frame_10 = QtWidgets.QFrame(self.tab_4)
        self.frame_10.setGeometry(QtCore.QRect(30, 410, 361, 71))
        self.frame_10.setStyleSheet("font-family:Helvetica;;background-color:#022859;border-radius:15px")
        self.frame_10.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_10.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_10.setObjectName("frame_10")
        self.terminalName_10 = QtWidgets.QLabel(self.frame_10)
        self.terminalName_10.setGeometry(QtCore.QRect(20, 10, 160, 21))
        self.terminalName_10.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.terminalName_10.setText("")
        self.terminalName_10.setObjectName("terminalName_10")
        self.terminalDGLabel_10 = QtWidgets.QLabel(self.frame_10)
        self.terminalDGLabel_10.setGeometry(QtCore.QRect(180, 10, 80, 21))
        self.terminalDGLabel_10.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalDGLabel_10.setObjectName("terminalDGLabel_10")
        self.terminalTGLabel_10 = QtWidgets.QLabel(self.frame_10)
        self.terminalTGLabel_10.setGeometry(QtCore.QRect(270, 10, 80, 21))
        self.terminalTGLabel_10.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalTGLabel_10.setObjectName("terminalTGLabel_10")
        self.terminalDG_10 = QtWidgets.QLabel(self.frame_10)
        self.terminalDG_10.setGeometry(QtCore.QRect(190, 30, 60, 21))
        self.terminalDG_10.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalDG_10.setText("")
        self.terminalDG_10.setObjectName("terminalDG_10")
        self.terminalTG_10 = QtWidgets.QLabel(self.frame_10)
        self.terminalTG_10.setGeometry(QtCore.QRect(280, 30, 60, 21))
        self.terminalTG_10.setStyleSheet("font-family:Helvetica;font-size:12px;color:#D97D0B")
        self.terminalTG_10.setText("")
        self.terminalTG_10.setObjectName("terminalTG_10")
        self.terminalUpdateTime_10 = QtWidgets.QLabel(self.frame_10)
        self.terminalUpdateTime_10.setGeometry(QtCore.QRect(20, 40, 151, 20))
        self.terminalUpdateTime_10.setStyleSheet("font-family:Helvetica;font-size:10px;color:White")
        self.terminalUpdateTime_10.setObjectName("terminalUpdateTime_10")
        self.tabWidget.addTab(self.tab_4, "")
        self.config_label_7 = QtWidgets.QLabel(self.centralwidget)
        self.config_label_7.setGeometry(QtCore.QRect(840, 40, 281, 20))
        self.config_label_7.setStyleSheet("font-family:Helvetica;font-size:15px;color:White")
        self.config_label_7.setAlignment(QtCore.Qt.AlignLeading|QtCore.Qt.AlignLeft|QtCore.Qt.AlignVCenter)
        self.config_label_7.setObjectName("config_label_7")
        self.tabWidget.raise_()
        self.terminalButton.raise_()
        self.terminalList.raise_()
        self.config_label.raise_()
        self.terminalEdit.raise_()
        self.checkBox.raise_()
        self.terminal_label.raise_()
        self.chatSelect.raise_()
        self.config_channels.raise_()
        self.chatList.raise_()
        self.channel_label.raise_()
        self.config_label_6.raise_()
        self.inputTab.raise_()
        self.saveButton.raise_()
        self.loadButton.raise_()
        self.authWarning.raise_()
        self.chatButton.raise_()
        self.config_label_7.raise_()
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtWidgets.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 1478, 21))
        self.menubar.setObjectName("menubar")
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtWidgets.QStatusBar(MainWindow)
        self.statusbar.setObjectName("statusbar")
        MainWindow.setStatusBar(self.statusbar)

        self.terminalButton.clicked.connect(self.updateTerminalList)
        self.chatButton.clicked.connect(self.updateSourceList)
        self.saveButton.clicked.connect(self.getInputs)
        self.loadButton.clicked.connect(self.loadInputs)      


        self.retranslateUi(MainWindow)
        self.inputTab.setCurrentIndex(0)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

        
    
    def updateTerminalList(self):
        try:
            global currentList
            currentTerminal = self.terminalEdit.text()
            for i in range(self.terminalList.count()):
                if str(self.terminalList.item(i).text()) not in currentList:
                 currentList.append(str(self.terminalList.item(i).text()))
            if len(currentTerminal) > 0 and currentTerminal not in currentList:
             currentList.append(currentTerminal)
            #log('Terminal list is '+str(currentList))
            self.terminalList.clear()
            self.terminalList.addItems(currentList)
            self.terminalEdit.setText('')
        except Exception as e:
            log('Failed to update source list. Error = '+str(e))
            #ui.signaltext.setText('Failed to update source list. Error = '+str(e))

    

    def updateSourceList(self):
        try:
            global allowed_chats
            currentSource = self.chatSelect.currentText()
            for i in range(self.chatList.count()):
                if str(self.chatList.item(i).text()) not in allowed_chats:
                 allowed_chats.append(str(self.chatList.item(i).text()))
            if len(currentSource) > 0 and currentSource not in allowed_chats:
             allowed_chats.append(currentSource)
            self.chatList.clear()
            self.chatList.addItems(allowed_chats)
        except Exception as e:
            log('Failed to update source list. Error = '+str(e))
    
    def getInputs(self):
       try:
          tab = self.inputTab
          for i in tab.children():
             for item in i.children():
              for elem in item.children():
               #print(str(type(elem)))
               if str(type(elem)).find('PyQt5.QtWidgets.QLineEdit') != -1:
                  #print(str(elem.objectName())," value is ",elem.text())
                  inputValues[str(elem.objectName())] = elem.text()
               elif str(type(elem)).find('PyQt5.QtWidgets.QComboBox') != -1:
                  #print(str(elem.objectName())," value is ",elem.currentText())
                  inputValues[str(elem.objectName())] = elem.currentText()
          #print('Inputs => ',str(inputValues))
          for i in currentList:
           terminal = os.path.join(i,'MQL4','Files')
           terminal2 = os.path.join(i,'MQL5','Files')
           if os.path.exists(terminal2) == True:
            if os.path.exists(os.path.join(terminal2,'gogi_inputs.txt')) == False:
              p = open(os.path.join(terminal2,'gogi_inputs.txt'),'x')
            with open(os.path.join(terminal2,'gogi_inputs.txt'), 'w', encoding="utf-8") as f:
              for key in inputValues.keys():
                f.write(key+':'+inputValues[key]+'\n')
           if os.path.exists(terminal) == True:
            if os.path.exists(os.path.join(terminal,'gogi_inputs.txt')) == False:
              p = open(os.path.join(terminal,'gogi_inputs.txt'),'x')
            with open(os.path.join(terminal,'gogi_inputs.txt'), 'w', encoding="utf-8") as f:
              for key in inputValues.keys():
                f.write(key+':'+inputValues[key]+'\n')
       except Exception as e:
          log('Failed to get tab elements. Error = '+str(e))
    
    def loadInputs(self):
        try:
            inputList = list()
            for i in currentList:
             terminal = os.path.join(i,'MQL4','Files')
             terminal2 = os.path.join(i,'MQL5','Files')
             if os.path.exists(terminal2) == True:
                if os.path.exists(os.path.join(terminal2,'gogi_inputs.txt')) == True:
                 with open(os.path.join(terminal2,'gogi_inputs.txt'), 'r', encoding="utf-8") as f:
                    inputList = f.readlines()
                    break
             elif os.path.exists(terminal) == True:
                if os.path.exists(os.path.join(terminal,'gogi_inputs.txt')) == True:
                 with open(os.path.join(terminal,'gogi_inputs.txt'), 'w', encoding="utf-8") as f:
                    inputList = f.readlines()
                    break
            print('Input list is ',inputList)
            tab = self.inputTab
            for i in tab.children():
             for item in i.children():
              for elem in item.children():
               for item in inputList:
                  if item.find(str(elem.objectName())) != -1:
                     name = ''
                     parts = list()
                     parts = item.split(':')
                     name = parts[1].replace('\n', '')
                     if str(type(elem)).find('PyQt5.QtWidgets.QLineEdit') != -1:
                        #print(str(elem.objectName()),' text value should be ',name)
                        elem.setText(name)
                        break
                     elif str(type(elem)).find('PyQt5.QtWidgets.QComboBox') != -1:
                        #print(str(elem.objectName()),' currentText value should be ',name)
                        elem.setCurrentText(name)
                        break
        except Exception as e:
            log('Failed to load inputs. Error = '+str(e))

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "Gogi"))
        self.terminalButton.setText(_translate("MainWindow", "Add ㊉"))
        self.config_label.setText(_translate("MainWindow", "Configure Terminals"))
        self.terminalEdit.setPlaceholderText(_translate("MainWindow", "Paste MT4/MT5 terminal path here"))
        self.checkBox.setText(_translate("MainWindow", "LOGOUT ON EXIT"))
        self.terminal_label.setText(_translate("MainWindow", "Terminal List"))
        self.config_channels.setText(_translate("MainWindow", "Configure Channels"))
        self.channel_label.setText(_translate("MainWindow", "Channel List"))
        self.config_label_6.setText(_translate("MainWindow", "Inputs"))
        self.excSym.setPlaceholderText(_translate("MainWindow", "Excluded Symbols"))
        self.incSym.setPlaceholderText(_translate("MainWindow", "Included Symbols"))
        self.brokerSym.setPlaceholderText(_translate("MainWindow", "Broker symbol suffix (if any)"))
        self.specialSym.setPlaceholderText(_translate("MainWindow", "Special symbol names on broker"))
        self.indicesList.setPlaceholderText(_translate("MainWindow", "Indices List"))
        self.commList.setPlaceholderText(_translate("MainWindow", "Commodities List"))
        self.cryptoList.setPlaceholderText(_translate("MainWindow", "Crypto List"))
        self.inputTab.setTabText(self.inputTab.indexOf(self.tab), _translate("MainWindow", "Symbol"))
        self.lotPerTPcrypto.setPlaceholderText(_translate("MainWindow", "Lot size per TP (crypto)"))
        self.lotPerTPindices.setPlaceholderText(_translate("MainWindow", "Lot size per TP (indices)"))
        self.lotValue.setPlaceholderText(_translate("MainWindow", "Lot value"))
        self.riskSource.setItemText(0, _translate("MainWindow", "Risk from free margin"))
        self.riskSource.setItemText(1, _translate("MainWindow", " Risk from account balance"))
        self.lotPerTPCurr.setPlaceholderText(_translate("MainWindow", "Lot size per TP (currencies)"))
        self.riskMode.setItemText(0, _translate("MainWindow", "Fixed"))
        self.riskMode.setItemText(1, _translate("MainWindow", "Risk"))
        self.riskPerc.setPlaceholderText(_translate("MainWindow", "Risk %"))
        self.lotPerSymbol.setPlaceholderText(_translate("MainWindow", "Lot size per symbol"))
        self.maxDD.setPlaceholderText(_translate("MainWindow", "Maximum drawdown (%)"))
        self.inputTab.setTabText(self.inputTab.indexOf(self.tab_2), _translate("MainWindow", "Risk"))
        self.defaultTPcurrencies.setPlaceholderText(_translate("MainWindow", "Default TP (currencies)"))
        self.addSpread.setItemText(0, _translate("MainWindow", "True"))
        self.addSpread.setItemText(1, _translate("MainWindow", "False"))
        self.addSpreadLabel.setText(_translate("MainWindow", "Add spread to SL"))
        self.addSpreadTPLabel.setText(_translate("MainWindow", "Add spread to TP"))
        self.addSpreadTP.setItemText(0, _translate("MainWindow", "True"))
        self.addSpreadTP.setItemText(1, _translate("MainWindow", "False"))
        self.defaultSLcurrencies.setPlaceholderText(_translate("MainWindow", "Default SL (currencies)"))
        self.defaultTPothers.setPlaceholderText(_translate("MainWindow", "Default TP (others)"))
        self.defaultSLothers.setPlaceholderText(_translate("MainWindow", "Default SL (others)"))
        self.rejectSL.setItemText(0, _translate("MainWindow", "True"))
        self.rejectSL.setItemText(1, _translate("MainWindow", "False"))
        self.rejectSLLabel.setText(_translate("MainWindow", "Reject orders without SL"))
        self.inputTab.setTabText(self.inputTab.indexOf(self.tab_3), _translate("MainWindow", "P ＆ L"))
        self.slMode.setItemText(0, _translate("MainWindow", "Signal"))
        self.slMode.setItemText(1, _translate("MainWindow", "Custom"))
        self.slModeLabel.setText(_translate("MainWindow", "SL Mode"))
        self.tpModeLabel.setText(_translate("MainWindow", "TP Mode"))
        self.tpMode.setItemText(0, _translate("MainWindow", "Signal"))
        self.tpMode.setItemText(1, _translate("MainWindow", "Custom"))
        self.multiTP.setItemText(0, _translate("MainWindow", "Multiple orders"))
        self.multiTP.setItemText(1, _translate("MainWindow", "Single order"))
        self.multiTPlabel.setText(_translate("MainWindow", "Multiple TP handle"))
        self.tradesPerTP.setPlaceholderText(_translate("MainWindow", "Number of trades per TP"))
        self.divLot.setItemText(0, _translate("MainWindow", "True"))
        self.divLot.setItemText(1, _translate("MainWindow", "False"))
        self.divLotLabel.setText(_translate("MainWindow", "Divide lot by count"))
        self.moveSL.setItemText(0, _translate("MainWindow", "True"))
        self.moveSL.setItemText(1, _translate("MainWindow", "False"))
        self.moveSLLabel.setText(_translate("MainWindow", "Move SL per TP hit"))
        self.dynamicSL.setPlaceholderText(_translate("MainWindow", "Dynamic SL"))
        self.inputTab.setTabText(self.inputTab.indexOf(self.tab_7), _translate("MainWindow", "P ＆ L (2)"))
        self.execLimitLabel.setText(_translate("MainWindow", "Execute by limit"))
        self.execLimit.setItemText(0, _translate("MainWindow", "True"))
        self.execLimit.setItemText(1, _translate("MainWindow", "False"))
        self.limitExpiry.setPlaceholderText(_translate("MainWindow", "Limit expiry (hours)"))
        self.numTrades.setPlaceholderText(_translate("MainWindow", "Number of trades (when no SL/TP)"))
        self.maxOrders.setPlaceholderText(_translate("MainWindow", "Max Order Count"))
        self.maxOrderPerSymbol.setPlaceholderText(_translate("MainWindow", "Max Order Count per symbol"))
        self.partialClosePerc.setPlaceholderText(_translate("MainWindow", "% for partial close"))
        self.beAfter.setPlaceholderText(_translate("MainWindow", "Breakeven trade after $$$"))
        self.closeTradeAfter.setPlaceholderText(_translate("MainWindow", "Close trade after $$$ drawdown"))
        self.showSender.setItemText(0, _translate("MainWindow", "True"))
        self.showSender.setItemText(1, _translate("MainWindow", "False"))
        self.showSenderLabel.setText(_translate("MainWindow", "Show Sender"))
        self.inputTab.setTabText(self.inputTab.indexOf(self.tab_8), _translate("MainWindow", "Trade"))
        self.shutdown.setItemText(0, _translate("MainWindow", "True"))
        self.shutdown.setItemText(1, _translate("MainWindow", "False"))
        self.shutdownLabel.setText(_translate("MainWindow", "Activate shutdown"))
        self.EACloseDay.setItemText(0, _translate("MainWindow", "Monday"))
        self.EACloseDay.setItemText(1, _translate("MainWindow", "Tuesday"))
        self.EACloseDay.setItemText(2, _translate("MainWindow", "Wednesday"))
        self.EACloseDay.setItemText(3, _translate("MainWindow", "Thursday"))
        self.EACloseDay.setItemText(4, _translate("MainWindow", "Friday"))
        self.EACloseDay.setItemText(5, _translate("MainWindow", "Saturday"))
        self.EACloseDay.setItemText(6, _translate("MainWindow", "Sunday"))
        self.EACloseDayLabel.setText(_translate("MainWindow", "EA Close day"))
        self.EACloseTime.setPlaceholderText(_translate("MainWindow", "EA Close time"))
        self.EARestartDay.setItemText(0, _translate("MainWindow", "Monday"))
        self.EARestartDay.setItemText(1, _translate("MainWindow", "Tuesday"))
        self.EARestartDay.setItemText(2, _translate("MainWindow", "Wednesday"))
        self.EARestartDay.setItemText(3, _translate("MainWindow", "Thursday"))
        self.EARestartDay.setItemText(4, _translate("MainWindow", "Friday"))
        self.EARestartDay.setItemText(5, _translate("MainWindow", "Saturday"))
        self.EARestartDay.setItemText(6, _translate("MainWindow", "Sunday"))
        self.EARestartDayLabel.setText(_translate("MainWindow", "EA Restart day"))
        self.EARestartTime.setPlaceholderText(_translate("MainWindow", "EA Restart time"))
        self.inputTab.setTabText(self.inputTab.indexOf(self.tab_9), _translate("MainWindow", "Time"))
        self.saveButton.setText(_translate("MainWindow", "Save"))
        self.loadButton.setText(_translate("MainWindow", "Load Prev."))
        self.chatButton.setText(_translate("MainWindow", "Add ㊉"))
        self.terminalDGLabel_2.setText(_translate("MainWindow", ""))
        self.terminalTGLabel_2.setText(_translate("MainWindow", ""))
        self.terminalUpdateTime_2.setText(_translate("MainWindow", ""))
        self.terminalDGLabel_3.setText(_translate("MainWindow", ""))
        self.terminalTGLabel_3.setText(_translate("MainWindow", ""))
        self.terminalUpdateTime_3.setText(_translate("MainWindow", ""))
        self.terminalDGLabel_4.setText(_translate("MainWindow", ""))
        self.terminalTGLabel_4.setText(_translate("MainWindow", ""))
        self.terminalUpdateTime_4.setText(_translate("MainWindow", ""))
        self.terminalDGLabel_5.setText(_translate("MainWindow", ""))
        self.terminalTGLabel_5.setText(_translate("MainWindow", ""))
        self.terminalUpdateTime_5.setText(_translate("MainWindow", ""))
        self.terminalDGLabel.setText(_translate("MainWindow", ""))
        self.terminalTGLabel.setText(_translate("MainWindow", ""))
        self.terminalUpdateTime.setText(_translate("MainWindow", ""))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab_5), _translate("MainWindow", "1"))
        self.terminalDGLabel_6.setText(_translate("MainWindow", ""))
        self.terminalTGLabel_6.setText(_translate("MainWindow", ""))
        self.terminalUpdateTime_6.setText(_translate("MainWindow", ""))
        self.terminalDGLabel_7.setText(_translate("MainWindow", ""))
        self.terminalTGLabel_7.setText(_translate("MainWindow", ""))
        self.terminalUpdateTime_7.setText(_translate("MainWindow", ""))
        self.terminalDGLabel_8.setText(_translate("MainWindow", ""))
        self.terminalTGLabel_8.setText(_translate("MainWindow", ""))
        self.terminalUpdateTime_8.setText(_translate("MainWindow", ""))
        self.terminalDGLabel_9.setText(_translate("MainWindow", ""))
        self.terminalTGLabel_9.setText(_translate("MainWindow", ""))
        self.terminalUpdateTime_9.setText(_translate("MainWindow", ""))
        self.terminalDGLabel_10.setText(_translate("MainWindow", ""))
        self.terminalTGLabel_10.setText(_translate("MainWindow", ""))
        self.terminalUpdateTime_10.setText(_translate("MainWindow", ""))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab_4), _translate("MainWindow", "2"))
        self.config_label_7.setText(_translate("MainWindow", "Masters"))



def get_env(name, message, cast=str):
    if name in os.environ:
        return os.environ[name]
    while True:
        value = input(message)
        try:
            return cast(value)
        except ValueError as e:
            print(e, file=sys.stderr)
            time.sleep(1)
  
def log(data):
     now = datetime.now()
     date  = now.strftime("%Y.%m.%d")
     time  = now.strftime("%H:%M:%S")
     for i in currentList:
      terminal = os.path.join(i,'MQL4','Files')
      terminal2 = os.path.join(i,'MQL5','Files')
      if os.path.exists(terminal2) == True:
        if os.path.exists(os.path.join(terminal2,'COPIER_LOG',date+'_Log.txt')) == False:
         os.makedirs(os.path.join(terminal2,'COPIER_LOG'), exist_ok=True)
         p = open(os.path.join(terminal2,'COPIER_LOG',date+'_Log.txt'),'x')
        with open(os.path.join(terminal2,'COPIER_LOG',date+'_Log.txt'), 'a', encoding="utf-8") as f:
            f.write(date+' '+time+' '+data+'\n'+'============================\n')
      elif os.path.exists(terminal) == True:
        if os.path.exists(os.path.join(terminal,'COPIER_LOG',date+'_Log.txt')) == False:
         os.makedirs(os.path.join(terminal,'COPIER_LOG'), exist_ok=True)
         p = open(os.path.join(terminal,'COPIER_LOG',date+'_Log.txt'),'x')
        with open(os.path.join(terminal,'COPIER_LOG',date+'_Log.txt'), 'a', encoding="utf-8") as f:
            f.write(date+' '+time+' '+data+'\n'+'============================\n')

session = 'user'#os.environ.get('TG_SESSION', 'loger')
api_id = 19533412
api_hash = '244adfc8d6a54f85df6958ac3823e203'
proxy = None  # https://github.com/Anorov/PySocks

# Create and start the client so we can make requests (we don't here)





# `pattern` is a regex, see https://docs.python.org/3/library/re.html
# Use https://regexone.com/ if you want a more interactive way of learning.
#
# "(?i)" makes it case-insensitive, and | separates "options".
def run_bot(queue_in, queue_out):
    if os.path.exists('user.session') == False:
            os._exit(0)
          
    #log("run_bot()")
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    #log('loop:', loop)
    
    client = TelegramClient(session, api_id, api_hash, proxy=proxy)
    

    def sendToMT4(data):
     for i in currentList:
      terminal = os.path.join(i,'MQL4','Files')
      terminal2 = os.path.join(i,'MQL5','Files')
      if os.path.exists(terminal2) == True:
        if os.path.exists(os.path.join(terminal2,'lastsignal.txt')) == False:
         p = open(os.path.join(terminal2,'lastsignal.txt'),'x')
        with open(os.path.join(terminal2,'lastsignal.txt'), 'w', encoding="utf-8") as f:
            f.write(data)
      if os.path.exists(terminal) == True:
        if os.path.exists(os.path.join(terminal,'lastsignal.txt')) == False:
         p = open(os.path.join(terminal,'lastsignal.txt'),'x')
        with open(os.path.join(terminal,'lastsignal.txt'), 'w', encoding="utf-8") as f:
            f.write(data)
      
    
        
        

    @client.on(events.NewMessage())
    async def handler(event):
        try:
            global IDs
            now = datetime.now()
            dt  = now.strftime("%d-%m-%Y, %H:%M:%S")
            msg = ''
            sender = ''
            user_id=event.message.to_dict()['peer_id']
            text = event.raw_text
            Messages[str(event.id)] = text
            text = text.upper()
            #log(user_id)
            if 'BUY' in text or 'SELL' in text:
                IDs[str(event.id)] = list()
            if 'PeerChannel' in str(user_id):
                user_id = user_id['channel_id']
                sender = await client.get_entity(user_id)
                sender = sender.to_dict()['title']
            elif 'PeerChat' in str(user_id):
                user_id = user_id['chat_id']
                sender = await client.get_entity(user_id)
                sender = sender.to_dict()['title']
            elif 'PeerUser' in str(user_id):
                user_id = user_id['user_id']
                sender = await client.get_entity(user_id)
                sender = sender.to_dict()['first_name']
            if sender not in allowed_chats:
                return           
            if event.is_reply:
                reply = await event.get_reply_message()
                reply_text = reply.raw_text
                #print('Type of reply is ',type(reply))
                # print('Messages list => ',all_messages)
                async for m in client.iter_messages(sender, limit=50):
                    #print('Type of m is ',type(m))
                    m_dict = m.to_dict()
                    #print('Message was ',m_dict['message'])
                    if m_dict['id'] == reply.id:
                        if m.photo:
                            #print('Replied message is an image')
                            img = await m.download_media('last_photo.png')
                            image = Image.open('last_photo.png')
                            image_data = np.asarray(image)
                            #img_read = cv2.imread('last_photo.png')
                            img_read = cv2.cvtColor(image_data, cv2.COLOR_BGR2RGB)
                            img_content = pytesseract.image_to_string(img_read)
                            #print('Reply raw text is ', reply.raw_text)
                            if len(reply.raw_text) == 0:
                             reply_text = img_content
                        break
                replyCopy = str(reply)
                replyCopy = replyCopy.upper()
                repID = str(reply.id)
                #log('Reply ID is ',repID)
                if replyCopy.find('BUY') != -1 or replyCopy.find('SELL') != -1:
                 IDs[repID].append(str(event.id))
                msg = reply_text+'|'+event.raw_text  + ' {' + str(reply.id) + '}'
                for k in IDs.keys():
                    #log('Key is ',k)
                    for item in IDs[k]:
                        #log('Item in ',k,' is ',item)
                        #log('Rep ID is ',str(event.id))
                        #log('Item is ',str(item))
                        if str(event.id) == str(item) or str(repID) == str(item):
                            msg = reply.raw_text+'|'+event.raw_text  + ' {' + k + '}'
                            break
            else:
             if event.photo:
                print('Image received')
                img = await event.download_media('last_photo.png')
                image = Image.open('last_photo.png')
                image_data = np.asarray(image)
                #img_read = cv2.imread('last_photo.png')
                img_read = cv2.cvtColor(image_data, cv2.COLOR_BGR2RGB)
                img_content = pytesseract.image_to_string(img_read)
                msg = img_content  + ' {' + str(event.id) + '}'
             else:
              msg = event.raw_text + ' {' + str(event.id) + '}'
            sendToMT4(sender+'\n'+msg)
            MSG = msg.upper()
            ##ui.signaltext.setText(dt+'\n'+'\n'+msg[:msg.find('{')]+'\n\nFROM: '+sender)
        except Exception as e:
            log('Failed to process last message. Error = '+str(e))
            ##ui.signaltext.setText('Failed to process last message. Error = '+str(e))
    
    @client.on(events.MessageEdited())
    async def handler(event):
        try:
            global IDs
            now = datetime.now()
            dt  = now.strftime("%d-%m-%Y, %H:%M:%S")
            msg = ''
            sender = ''
            user_id=event.message.to_dict()['peer_id']
            text = event.raw_text
            log('Message was edited.\n Old content = '+Messages[str(event.id)]+'.\n New content = '+text)
            Messages[str(event.id)] = text
            text = text.upper()
            #log(user_id)
            if 'BUY' in text or 'SELL' in text:
                IDs[str(event.id)] = list()
            if 'PeerChannel' in str(user_id):
                user_id = user_id['channel_id']
                sender = await client.get_entity(user_id)
                sender = sender.to_dict()['title']
            elif 'PeerChat' in str(user_id):
                user_id = user_id['chat_id']
                sender = await client.get_entity(user_id)
                sender = sender.to_dict()['title']
            elif 'PeerUser' in str(user_id):
                user_id = user_id['user_id']
                sender = await client.get_entity(user_id)
                sender = sender.to_dict()['first_name']
            if sender not in allowed_chats:
                return           
            if event.is_reply:
                reply = await event.get_reply_message()
                reply_text = reply.raw_text
                #print('Type of reply is ',type(reply))
                # print('Messages list => ',all_messages)
                async for m in client.iter_messages(sender, limit=50):
                    #print('Type of m is ',type(m))
                    m_dict = m.to_dict()
                    #print('Message was ',m_dict['message'])
                    if m_dict['id'] == reply.id:
                        if m.photo:
                            #print('Replied message is an image')
                            img = await m.download_media('last_photo.png')
                            image = Image.open('last_photo.png')
                            image_data = np.asarray(image)
                            #img_read = cv2.imread('last_photo.png')
                            img_read = cv2.cvtColor(image_data, cv2.COLOR_BGR2RGB)
                            img_content = pytesseract.image_to_string(img_read)
                            #print('Reply raw text is ', reply.raw_text)
                            if len(reply.raw_text) == 0:
                             reply_text = img_content
                        break
                replyCopy = str(reply)
                replyCopy = replyCopy.upper()
                repID = str(reply.id)
                #log('Reply ID is ',repID)
                if replyCopy.find('BUY') != -1 or replyCopy.find('SELL') != -1:
                 IDs[repID].append(str(event.id))
                msg = reply.raw_text+'|'+event.raw_text  + ' {' + str(reply.id) + '}'
                for k in IDs.keys():
                    #log('Key is ',k)
                    for item in IDs[k]:
                        #log('Item in ',k,' is ',item)
                        #log('Rep ID is ',str(event.id))
                        #log('Item is ',str(item))
                        if str(event.id) == str(item) or str(repID) == str(item):
                            msg = reply.raw_text+'|'+event.raw_text  + ' {' + k + '}'
                            break
            else:
             if event.photo:
                print('Image received')
                img = await event.download_media('last_photo.png')
                image = Image.open('last_photo.png')
                image_data = np.asarray(image)
                #img_read = cv2.imread('last_photo.png')
                img_read = cv2.cvtColor(image_data, cv2.COLOR_BGR2RGB)
                img_content = pytesseract.image_to_string(img_read)
                msg = img_content  + ' {' + str(event.id) + '}'
             else:
                msg = event.raw_text + ' {' + str(event.id) + '}'
            sendToMT4(sender+'\n'+msg)
            MSG = msg.upper()
            #ui.signaltext.setText(dt+'\n'+'\n'+msg[:msg.find('{')]+'\n\nFROM: '+sender)
        except Exception as e:
            log('Failed to process last message. Error = '+str(e))
            #ui.signaltext.setText('Failed to process last message. Error = '+str(e))
    
    async def check_queue():
        #log('[BOT] check_queue(): start')
        while True:
            await asyncio.sleep(1)
            # log('[BOT] check_queue(): check')
            if not queue_in.empty():
                cmd = queue_in.get()
                #log('[BOT] check_queue(): queue_in get:', cmd)
                if cmd == 'stop':
                 log('Stopping bot...')
                 await client.disconnect()
                 os._exit(0)
                 break
                if cmd == 'logout':
                 log('Logging out...')
                 await client.log_out()
    
    async def auth_warning():
        while True:
                await asyncio.sleep(1)
                try:
                  if await client.is_user_authorized() == False:
                    ui.authWarning.setText('You are not logged in to a Telegram account. Please close this application and run sign_in.exe first.')
                  else:
                    ui.authWarning.setText('')
                except Exception as e:
                    log('Failed to warn auth. Error = '+str(e))

    async def update_sources():
        global channel_list
        log('Channels are '+str(channel_list))       
        if len(channel_list) == 0:
            while True:     
                await asyncio.sleep(1)
                try:   
                        channels = list()
                        await client.connect()

                        if await client.is_user_authorized():
                            async for dialog in client.iter_dialogs():
                                #log('Channel is ',dialog.title)
                                if dialog.is_user == False:
                                    channels.append(dialog.title)
                            channel_list = list(channels)
                            ui.chatSelect.clear()
                            ui.chatSelect.addItems(channel_list)
                            break
                except Exception as e:
                    log('Failed to update sources. Error = '+str(e))
                    #ui.signaltext.setText('Failed to update sources. Error = '+str(e))
        else:
            pass

    async def showTerminalInfo():
     while True:
        await asyncio.sleep(1)
        try:
            if IsUISetup == False:
             #print('UI not defined yet')
             continue
            else:
             #print('UI defined')
             pass
            Names = [ui.terminalName,ui.terminalName_2,ui.terminalName_3,ui.terminalName_4,ui.terminalName_5,ui.terminalName_6,ui.terminalName_7,ui.terminalName_8,ui.terminalName_9,ui.terminalName_10]
            DG = [ui.terminalDG,ui.terminalDG_2,ui.terminalDG_3,ui.terminalDG_4,ui.terminalDG_5,ui.terminalDG_6,ui.terminalDG_7,ui.terminalDG_8,ui.terminalDG_9,ui.terminalDG_10]
            TG = [ui.terminalTG,ui.terminalTG_2,ui.terminalTG_3,ui.terminalTG_4,ui.terminalTG_5,ui.terminalTG_6,ui.terminalTG_7,ui.terminalTG_8,ui.terminalTG_9,ui.terminalTG_10]
            DGLabel = [ui.terminalDGLabel,ui.terminalDGLabel_2,ui.terminalDGLabel_3,ui.terminalDGLabel_4,ui.terminalDGLabel_5,ui.terminalDGLabel_6,ui.terminalDGLabel_7,ui.terminalDGLabel_8,ui.terminalDGLabel_9,ui.terminalDGLabel_10]
            TGLabel = [ui.terminalTGLabel,ui.terminalTGLabel_2,ui.terminalTGLabel_3,ui.terminalTGLabel_4,ui.terminalTGLabel_5,ui.terminalTGLabel_6,ui.terminalTGLabel_7,ui.terminalTGLabel_8,ui.terminalTGLabel_9,ui.terminalTGLabel_10]
            Time = [ui.terminalUpdateTime,ui.terminalUpdateTime_2,ui.terminalUpdateTime_3,ui.terminalUpdateTime_4,ui.terminalUpdateTime_5,ui.terminalUpdateTime_6,ui.terminalUpdateTime_7,ui.terminalUpdateTime_8,ui.terminalUpdateTime_9,ui.terminalUpdateTime_10]
            #print(currentList)
            for num,i in enumerate(currentList):
                info = []
                terminal = os.path.join(i,'MQL4','Files')
                terminal2 = os.path.join(i,'MQL5','Files')
                terminalMode = ''
                if os.path.exists(terminal2) == True and os.path.exists(os.path.join(i,'MQL4')) == True:
                 terminalMode = 'MT5'
                elif os.path.exists(terminal) == True and os.path.exists(terminal2) == False:
                 terminalMode = 'MT4'
                
                if terminalMode == 'MT5':
                    filepath = os.path.join(terminal2,'gogi_terminalInfo.txt')
                    #print(filepath,' is MT5')
                    with open(filepath, 'r', encoding='utf-8') as f:
                        info = f.readlines()
                    #print('Info is ',str(info))
                    Names[num].setText(str(num+1)+'. '+info[0].replace('\n',''))
                    dailyPL = info[1].replace('\n','')
                    totalPL = info[2].replace('\n','')
                    #print('Daily PL is ',dailyPL)
                    '''if float(dailyPL.replace('$','')) < 0:
                     DG[num].setStyleSheet("font-family:Helvetica;QLabel {font-size:12px; color:#D97D0B}")
                    elif float(dailyPL.replace('$','')) >= 0:
                     DG[num].setStyleSheet("font-family:Helvetica;QLabel {font-size:12px; color:#D97D0B}")
                    if float(totalPL.replace('$','')) < 0:
                     TG[num].setStyleSheet("font-family:Helvetica;QLabel {font-size:12px; color:#D97D0B}")
                    elif float(totalPL.replace('$','')) >= 0:
                     TG[num].setStyleSheet("font-family:Helvetica;QLabel {font-size:12px; color:#D97D0B}")'''
                    DG[num].setText(dailyPL)
                    TG[num].setText(totalPL)
                    DGLabel[num].setText('Daily Gain/Loss')
                    TGLabel[num].setText('Total Gain/Loss')
                    Time[num].setText('Updated at: '+info[3].replace('\n',''))
                if terminalMode == 'MT4':
                    filepath = os.path.join(terminal,'gogi_terminalInfo.txt')
                    #print(filepath,' is MT4')
                    with open(filepath, 'r', encoding='utf-8') as f:
                        info = f.readlines()
                    #print('Info is ',str(info))
                    Names[num].setText(str(num+1)+'. '+info[0].replace('\n',''))
                    dailyPL = info[1].replace('\n','')
                    totalPL = info[2].replace('\n','')
                    #print('Daily PL is ',dailyPL)
                    '''if float(dailyPL.replace('$','')) < 0:
                     DG[num].setStyleSheet("font-family:Helvetica;QLabel {font-size:12px; color:#D97D0B}")
                    elif float(dailyPL.replace('$','')) >= 0:
                     DG[num].setStyleSheet("font-family:Helvetica;QLabel {font-size:12px; color:#D97D0B}")
                    if float(totalPL.replace('$','')) < 0:
                     TG[num].setStyleSheet("font-family:Helvetica;QLabel {font-size:12px; color:#D97D0B}")
                    elif float(totalPL.replace('$','')) >= 0:
                     TG[num].setStyleSheet("font-family:Helvetica;QLabel {font-size:12px; color:#D97D0B}")'''
                    DG[num].setText(info[1].replace('\n',''))
                    TG[num].setText(info[2].replace('\n',''))
                    DGLabel[num].setText('Daily Gain/Loss')
                    TGLabel[num].setText('Total Gain/Loss')
                    Time[num].setText('Updated at: '+info[3].replace('\n',''))
        except Exception as e:
           log('Terminal info retrieval failed. Error = '+str(e))
            
                
        
   

    loop.create_task(update_sources())
    loop.create_task(auth_warning())
    loop.create_task(check_queue())
    loop.create_task(showTerminalInfo())
   

    try:
     with client:
        #log('[BOT] start')
        client.run_until_disconnected()
        log('Client disconnected.')
    except Exception as e:
        ui.authWarning.setText(str(sys.exc_info()[1])+').\n Please check your internet connection\nand restart application.')
        log('Failed to run bot. Error = '+str(e))
    
    
    



def sendTradeInfo():
    global LastTradeInfo
    while True:
        try:
            info = ''
            c = socket.socket()
            #log('Socket created')
            c.connect(('localhost', 9999))
            info = c.recv(1024).decode()
            if LastTradeInfo != info:
             log(info)
             try:
                message = smsClient.messages.create(
                                    body=info,
                                    from_=ui.sourcePhone.text(),
                                    to=ui.destPhone.text()
                                )
                log(message.status)
                #ui.signaltext.setText(info)
                LastTradeInfo = info
             except Exception as e:
                #ui.signaltext.setText('Failed to send text for last trade. Error = '+str(e))
                log('Failed to send text for last trade. Error = '+str(e))
            time.sleep(2)
        except Exception as e:
         log('Sending trade info failed. Error = '+ str(e))
        
        


 
queue_in = Queue()  # to send data to bot
queue_out = Queue()  # to receive data from bot
thread2 = Thread(target=run_bot, args=(queue_in, queue_out))
thread2.start()

#tradeinfo = Thread(target=sendTradeInfo)
#tradeinfo.start()


#check_connect_thread = Thread(target=close_on_disconnect, args=(), daemon=True)
#check_connect_thread.start()

if __name__ == "__main__":
    import sys
    app = QtWidgets.QApplication(sys.argv)
    MainWindow = QtWidgets.QMainWindow()
    ui = Ui_MainWindow()
    ui.setupUi(MainWindow, queue_in, queue_out)
    IsUISetup = True
    MainWindow.show()
    app.exec_()
    checkState = int(ui.checkBox.checkState())
    if checkState == 0:
     print('User not logged out')
     queue_in.put('stop')
     thread2.join()
     os._exit(0)
    elif checkState == 2:
     queue_in.put('logout')
     thread2.join()
     print('User logged out')
     os._exit(0)







# Note: We used try/finally to show it can be done this way, but using:
#
#   with client:
#       client.run_until_disconnected()
#
# is almost always a better idea.
