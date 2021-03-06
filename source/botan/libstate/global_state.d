/**
* Global State Management
* 
* Copyright:
* (C) 2010 Jack Lloyd
* (C) 2014-2015 Etienne Cimon
*
* License:
* Botan is released under the Simplified BSD License (see LICENSE.md)
*/
module botan.libstate.global_state;
import botan.constants;
import botan.libstate.libstate;
import core.thread : Thread;
/// Thread-Local, no locks needed.
private LibraryState g_lib_state;

static ~this() { 
	if (g_lib_state)
		g_lib_state.destroy(); 

	if (Thread.getThis() != gs_ctor) return;
	if (gs_global_prng)
		gs_global_prng.destroy();
	if (gs_sources.length > 0) {
		gs_sources.clear();
		gs_sources.destroy();
	}
}

/**
* Access the global library state
* Returns: reference to the global library state
*/
LibraryState globalState()
{
    if (!g_lib_state) { 

        g_lib_state = new LibraryState;
        /* Lazy initialization. Botan still needs to be deinitialized later
            on or memory might leak.
        */
        g_lib_state.initialize();
    }
    return g_lib_state;
}

/**
* Set the global state object
* Params:
*  new_state = the new global state to use
*/
void setGlobalState(LibraryState new_state)
{
    if (g_lib_state) destroy(g_lib_state);
    g_lib_state = new_state;
}


/**
* Set the global state object unless it is already set
* Params:
*  new_state = the new global state to use
* Returns: true if the state parameter is now being used as the global
*            state, or false if one was already set, in which case the
*            parameter was deleted immediately
*/
bool setGlobalStateUnlessSet(LibraryState new_state)
{
    if (g_lib_state)
    {
        return false;
    }
    else
    {
        g_lib_state = new_state;
        return true;
    }
}

/**
* Query if the library is currently initialized
* Returns: true iff the library is initialized
*/
bool globalStateExists()
{
    return (g_lib_state !is LibraryState.init);
}