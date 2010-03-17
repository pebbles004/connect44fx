package org.jfxworks.connect44fx;

import java.lang.RuntimeException;
import javafx.reflect.FXLocal;
import java.lang.Exception;


/**
 * A mixin class used to enable event listening and dispatching for a class.
 *
 * It's written to the analogy of flex' class with the same name (argh) as there
 * is currently no consise way to do this in JavaFX.
 *
 * It's current limitations :
 * - Callback functions as limited to functions with max 5 arguments and a Void return type. (didn't find the way yet to do this generic)
 * - Doesn't check at dispatch time whether the function signature matches the passed arguments.
 * - Weak referenced listeners. So you need to remove listeners to avoid memory leaks !!!
 */
public mixin class EventDispatcher {

    /**
     * Override this variable to declare the event types the class will dispatch !
     */
    var eventTypes: String[] = [];
    var entries: EventTypeEntry[];

    def context      = FXLocal.getContext();
    def mirrorOfThis = context.mirrorOf( this );
    def typeOfThis   = mirrorOfThis.getType();

    /**
     * Find the event types declared by the implementing class.
     * The naming convention is that the name should start with 'EVENT_TYPE_' AND it should be a String
     */
    postinit {
        for ( variable in typeOfThis.getVariables( true ) ) {
            if ( variable.getName().startsWith("EVENT_TYPE_") and "java.lang.String".equals( variable.getType().getName() ) ) {
                def value = variable.getValue( mirrorOfThis ).getValueString();
                delete value from eventTypes;
                insert value into eventTypes;
            }
        }
    }

    public function addEventListener( type:String, callbackFunction:Object ) :Void {

        // the event type must be known by the dispatcher
        if ( sizeof eventTypes[ x | x == type ] == 0 ) {
            throw new RuntimeException( "Unknown event type '{type}'" );
        }

        // is the callback function argument a function ?
        if ( not isFunction( callbackFunction ) ) {
            throw new RuntimeException("The passed callback is not a function !")
        }

        // Add the listener to the event type
        def entry = entries[ x | x.type == type ];
        if ( sizeof entry == 0 ) {
            insert EventTypeEntry {
                type: type;
                listeners: callbackFunction;
            } into entries;
        }
        else {
            insert callbackFunction into entry[0].listeners;
        }
    };

    /**
     * Check whether the passed object is a valid callback function.
     * TODO Find a generic way to check this.
     */
    function isFunction( callback:Object ) :Boolean {
        try {
            def test = (callback as function(:Object):Void);
            return true;
        } catch ( Exception:Exception ) {}
        try {
            def test = (callback as function(:Object,:Object):Void);
            return true;
        } catch ( Exception:Exception ) {}
        try {
            def test = (callback as function(:Object,:Object,:Object):Void);
            return true;
        } catch ( Exception:Exception ) {}
        try {
            def test = (callback as function(:Object,:Object,:Object,:Object):Void);
            return true;
        } catch ( Exception:Exception ) {}
        try {
            def test = (callback as function(:Object,:Object,:Object,:Object,:Object):Void);
            return true;
        } catch ( Exception:Exception ) {}

        return false;
    }


    public function removeEventListener( type:String, callbackFunction:Object ) :Void {
        def entry = entries[ x | x.type == type ];
        if ( sizeof entry > 0 ) {
            delete callbackFunction from entry[0].listeners;
        }
    }

/**
 * The dispatch function is repeated for an ever longer list of arguments. This way the calling code is clean.
 * Writing one function accepting a sequence of Objects would work too but then the calling function should
 * explicitly declare a sequence.
 */

    public function dispatch( type:String, arg0:Object ) {
        def entry = entries[ x | x.type == type ];
        if ( sizeof entry > 0 ) {
            for ( listener in entry[0].listeners ) {
                (listener as function( :Object ))( arg0 );
            }
        }
    }

    public function dispatch( type:String, arg0:Object, arg1:Object ) {
        def entry = entries[ x | x.type == type ];
        if ( sizeof entry > 0 ) {
            for ( listener in entry[0].listeners ) {
                (listener as function( :Object, :Object ))( arg0, arg1 );
            }
        }
    }

    public function dispatch( type:String, arg0:Object, arg1:Object, arg2:Object ) {
        def entry = entries[ x | x.type == type ];
        if ( sizeof entry > 0 ) {
            for ( listener in entry[0].listeners ) {
                (listener as function( :Object, :Object,:Object ))( arg0, arg1, arg2 );
            }
        }
    }

    public function dispatch( type:String, arg0:Object, arg1:Object, arg2:Object, arg3:Object ) {
        def entry = entries[ x | x.type == type ];
        if ( sizeof entry > 0 ) {
            for ( listener in entry[0].listeners ) {
                (listener as function( :Object, :Object, :Object, :Object ))( arg0, arg1, arg2, arg3 );
            }
        }
    }

    public function dispatch( type:String, arg0:Object, arg1:Object, arg2:Object, arg3:Object, arg4:Object ) {
        def entry = entries[ x | x.type == type ];
        if ( sizeof entry > 0 ) {
            for ( listener in entry[0].listeners ) {
                (listener as function( :Object, :Object, :Object, :Object, :Object ))( arg0, arg1, arg2, arg3, arg4 );
            }
        }
    }
}

class EventTypeEntry {
    public-init var type:String;
    public var listeners: Object[];
}
