#!/bin/bash
oc() { 
    bin/oc_wrapper.sh $@ 
}

oc $@
