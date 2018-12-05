#!/usr/bin/env python
"""This exports a WSGI application"""
from spin import spin
from bottle import route, default_app

application = default_app()
