#!/usr/bin/env python
"""This module spins the CPU."""
import os
import time
import newrelic.agent
import random
from bottle import route, default_app, response

newrelic_ini = '../newrelic.ini'
if os.path.isfile(newrelic_ini):
    newrelic.agent.initialize(newrelic_ini)

@route('/spin')
def spin(delay=0.1):
    """Spin the CPU, return the process id at the end"""
    child_pid = os.getpid()
    upper_max = 100000000000000000000000000000000

    # Use a pareto distribution to give additional
    # variation to the delay
    # See https://en.wikipedia.org/wiki/Pareto_distribution
    alpha = 2
    pareto_factor = random.paretovariate(alpha)
    start_time = time.time()

    current_time = start_time
    scratch = 42 + int(current_time)
    end_time = start_time + (delay * pareto_factor)
    calcs = 0
    while current_time < end_time:
        calcs += 1
        scratch = (scratch * scratch) % upper_max
        current_time = time.time()
    final_time = time.time()
    interval = final_time - start_time
    rate = calcs / interval
    response.set_header('Content-Type', 'text/plain')
    return ('pid {0} spun {1} times over {2}s (rate {3}/s)\n'
            .format(child_pid, calcs, interval, rate))

application = default_app()
