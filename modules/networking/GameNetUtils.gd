"""
Author: Leonardo Spaccini
"""
extends Node

func parseTcpConnectionStatus(status : StreamPeerTCP.Status):
	if(status == 0): return "Not Connected";
	elif(status == 1): return "Connecting";
	elif(status == 2): return "Connected";
	elif(status == 3): return "Error";
