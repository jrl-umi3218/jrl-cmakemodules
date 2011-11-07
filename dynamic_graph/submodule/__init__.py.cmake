"""
    Copyright 2010 CNRS

    Author: Florent Lamiraux
"""
import sys, DLFCN
import dynamic_graph as dg
flags = sys.getdlopenflags()
# Import C++ symbols in a global scope
# This is necessary for signal compiled in different modules to be compatible
sys.setdlopenflags(DLFCN.RTLD_NOW|DLFCN.RTLD_GLOBAL)
import wrap
# Recover previous flags
sys.setdlopenflags(flags)

dg.entity.updateEntityClasses(globals())

${ENTITY_CLASS_LIST}
