#!/usr/bin/env python
"""This module spins the CPU."""
import os
import time
import random
import socket
import urllib2
import newrelic.agent
from bottle import route, default_app, response, HTTPError

NEWRELIC_INI = "../newrelic.ini"
if os.path.isfile(NEWRELIC_INI):
    newrelic.agent.initialize(NEWRELIC_INI)


@route("/spin")
def spin(delay=0.05, max_duration=10.0, simulate_congestion=True):
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
    congestion_slowdown = 0.0
    if simulate_congestion:
        congestion_slowdown = delay * 2 / (current_time - spin.last_time)
    end_time = start_time + (delay + congestion_slowdown) * pareto_factor
    time_limit = start_time + (max_duration)
    calcs = 0
    while current_time < end_time:
        calcs += 1
        scratch = (scratch * scratch) % upper_max
        current_time = time.time()
        interval = current_time - start_time
        if current_time > time_limit:
            raise HTTPError(
                500,
                "Allowed transaction time exceeded ({} ms elapsed)".format(interval),
            )
    spin.last_time = current_time
    rate = calcs / interval
    response.set_header("Content-Type", "text/plain")
    return "node {0} pid {1} spun {2} times over {3}s (rate {4} invoked {5} times. Congestion slowdown {6}s)\n".format(
        spin.node, child_pid, calcs, interval, rate, spin.invocations, congestion_slowdown
    )


spin.invocations = 0
spin.last_time = time.time() - 10
spin.slowdown = 0
try:
    # Thanks stack overflow https://stackoverflow.com/a/43816449/424301
    spin.node = urllib2.urlopen(
        "http://169.254.169.254/latest/meta-data/instance-id", timeout=1
    ).read()
# Thanks stack overflow https://stackoverflow.com/questions/2712524/handling-urllib2s-timeout-python
except urllib2.URLError:
    # Thanks stack overflow: https://stackoverflow.com/a/4271755/424301
    spin.node = socket.gethostname()

application = default_app()
