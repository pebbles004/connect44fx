/*
 * Observer.fx
 *
 * Meant to represent the final implementation of the Observer pattern.
 *
 * Until an even better solution comes up of course...
 *
 * Jan Goyvaerts @ JFXWorks (http://jfxworks.wordpress.com)
 * Created on Feb 19, 2010, 1:56:35 PM
 */

package org.jfxworks.patterns;

import java.lang.IllegalArgumentException;
import java.lang.IllegalStateException;
import javafx.reflect.FXLocal;
import javafx.util.Sequences;
import java.lang.ref.WeakReference;

/**
 * A mixin class every observer/listener should implement
 * in order to get events.
 */
public mixin class EventListener {
    public abstract function handleEvent( event:Event ):Void;

    public function getListener() :EventListener {
        return this;
    }
}

/**
 * EventListener wrapping another event listener with a weak reference.
 */
class WeakReferencedEventListener extends EventListener {
    var referent:EventListener;
    var reference:WeakReference;

    postinit {
        if ( referent == null ) {
            throw new IllegalStateException("A referent event listener should have been set.");
        }
        // put the referent into a weak reference
        reference = new WeakReference( referent );
        // cut the hard reference
        referent  = null;
    }

    override public function handleEvent (event : Event) :Void {
        def referent = reference.get();
        // is it still referencing something ?
        if ( referent != null ) {
            (referent as EventListener).handleEvent(event);
        }
    }

    override public function getListener() :EventListener {
        return reference.get() as EventListener;
    }
}


/**
 * Event class to allow the generic usage of events.
 * Override the 'type' variable to assign a new value.
 *
 * Class TestEvent extends Event {
 *   override def type = "test";
 * }
 *
 * It is created as a mixin class to allow any object
 * to become an event class. Even one of your domain classes.
 */
public mixin class Event {
    var typeSet = false;
    // make the type variable immutable. It can not be made protected
    // because subclasses might reset it. It can not be made public-init
    // because everyone can override the value. It can't be a def
    // because you can't override it.
    public var type:String on replace {
                                    if ( typeSet ) {
                                        throw new IllegalStateException("Can not reset the type value. Override the 'type' variable instead.");
                                    }
                                    typeSet = true;
                               };
}

/**
 * Mixin class to be implemented by each class dispatching events.
 *
 * The implementing class has to declare the event types it will handle
 * simply by declaring public String variables named EVENT_TYPE_.
 *
 * In theory this class could be final as it contains all needed code
 * to register, unregister and dispatch events.
 */
public mixin class EventDispatcher {

    // event types the dispatcher can handle
    protected var eventTypes: String[];

    // a map-like structure to store the listeners per event type.
    var listeners:EventListenerEntry[];

    // indicates whether the listeners should be weak-referenced
    public-init var weakReferenced = false;

    // stuff needed to find the event types by introspection
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
                insert value into eventTypes;
            }
        }
        // check for duplicates - they might mean identical values for different event types
        var lastType = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
        for ( type in Sequences.sort( eventTypes ) ) {
            if ( type == lastType ) {
                throw new IllegalStateException("Duplicate event type naming ! name= {type}");
            }
            lastType = type as String;
        }
    }

    // Add an observer to the list of observers
    public function addEventListener( type:String, listener:EventListener ) :Void {
        // check arguments
        if ( type == null or type.trim().equals("") or listener == null ) {
            throw new IllegalArgumentException("Invalid arguments: type= {type} listener= {listener}");
        }
        
        // get the type
        def types = eventTypes[ x | x.equals(type) ];
        if ( sizeof types == 0 ) {
            throw new IllegalArgumentException("Type {type} is not a subscribable type for this object.");
        }

        // make the registration
        def entry = listeners[ x | x.type == type ];

        // this should NOT happen !
        if ( sizeof entry > 1 ) {
            throw new IllegalStateException("More than one entry for event type {type} !");
        }
        // a new entry
        else if ( sizeof entry == 0 ) {
            insert EventListenerEntry {
                type: type
                listeners: adaptListener( listener )
            } into listeners;
        }
        // an existing entry
        else {
            insert adaptListener(listener) into entry[0].listeners;
        }

        // cleanup invalid listeners
        cleanupListeners();
    }

    function adaptListener( listener:EventListener ) :EventListener {
        if ( weakReferenced ) {
            WeakReferencedEventListener {
                referent: listener
            }
        }
        else {
            listener;
        }
    }

    // Remove the given observer from the list of known observers
    public function removeEventListener( type:String, listener:EventListener ) :Void {
        // make the unrgistration
        def entry = listeners[ x | x.type == type ];

        // this should NOT happen !
        if ( sizeof entry > 1 ) {
            throw new IllegalStateException("More than one entry for event type {type} !");
        }
        else if ( sizeof entry == 1 ) {
            def toDelete = entry[0].listeners[ x | x.getListener() == listener ];
            for ( del in toDelete ) {
                delete del from entry[0].listeners;
            }
        }

        // cleanup invalid listeners
        cleanupListeners();
    }

    // Dispatch the event to the known observers
    public function dispatch( event:Event ) :Void {
        // check arguments
        if ( event == null or event.type == null or event.type.trim().equals("") ) {
            throw new IllegalArgumentException("Invalid arguments: event= {event} type= {event.type}");
        }

        // check the type
        def types = eventTypes[ x | x.equals(event.type) ];
        if ( sizeof types == 0 ) {
            throw new IllegalArgumentException("Type {event.type} is not a subscribable type for this object.");
        }

        // dispatch
        def type  = types[0];
        def entry = listeners[ x | x.type == type ];
        if ( sizeof entry == 1 ) {
            for ( listener in entry[0].listeners ) {
                listener.handleEvent( event );
            }
        }

        // cleanup invalid listeners
        cleanupListeners();
    }

    /**
     * This code is really meant for weak references being freed
     */
    function cleanupListeners() :Void {
        for ( entry in listeners, listener in entry.listeners[ x | x.getListener() == null ]  ) {
            delete listener from entry.listeners;
        }
    }
}



/**
 * One entry in map-like structure of listeners/event type
 */
class EventListenerEntry {
    public-init var type:String;
    public var listeners:EventListener[];
}
