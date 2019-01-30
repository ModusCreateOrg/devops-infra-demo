#!/usr/bin/env python
"""x"""

if __name__ == "__main__":
    from spin import spin
    from bottle import run, default_app

    run(host="localhost", port=8080, debug=True)
