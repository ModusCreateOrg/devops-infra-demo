#!/usr/bin/env python
"""This module spins the CPU."""
import os
import time
import newrelic.agent
import random
from bottle import route, default_app, response, HTTPError

newrelic_ini = '../newrelic.ini'
if os.path.isfile(newrelic_ini):
    newrelic.agent.initialize(newrelic_ini)


@route('/spin')
def spin(delay=0.1):
    """Spin the CPU, return the process id at the end"""
    spin.invocations += 1
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
    end_time = start_time + pareto_factor * (delay + (delay * 10 / (current_time - spin.last_time)))
    time_limit = start_time + (delay * 50)
    calcs = 0
    while current_time < end_time:
        calcs += 1
        scratch = (scratch * scratch) % upper_max
        current_time = time.time()
        interval = current_time - start_time
        if current_time > time_limit:
            raise HTTPError(500, "Allowed transaction time exceeded ({} ms elapsed)".format(interval))
    spin.last_time = current_time
    rate = calcs / interval
    response.set_header('Content-Type', 'text/plain')
    return ('pid {0} spun {1} times over {2}s (rate {3} invoked {4} times/s)\n'
            .format(child_pid, calcs, interval, rate, spin.invocations))

spin.invocations = 0
spin.last_time = time.time() - 10
spin.slowdown = 0

application = default_app()
