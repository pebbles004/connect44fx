/*
 * Implementation.fx
 *
 * Unit test suite for the observer.Implementation class
 *
 * TODO: Test Envent.type immutability. Apparently triggers are executed asynchronously.
 *
 * Created on Feb 19, 2010, 2:50:39 PM
 */

package org.jfxworks.patterns.test;

import junit.textui.TestRunner;
import org.jfxworks.patterns.Observer.*;
import java.lang.UnsupportedOperationException;

import junit.framework.TestSuite;
import java.lang.IllegalArgumentException;
import java.lang.IllegalStateException;
import java.lang.System;
import org.jfxworks.test.JFXTestCase;

//////////////////////////////////////////////////////////////////////////////////////////
// VERY IMPORTANT !!!!! Put these ON TOP of the source code !!!! Otherwise you'll end up
//                      Using nulls in the init and postinit blocks !!!!
//////////////////////////////////////////////////////////////////////////////////////////
public def EVENT_TYPE_WAKEUP:String = "wakeup";
public def EVENT_TYPE_SLEEP:String  = "sleep";
public var testWeakReferences = true;
public var weakEventCounter = 0;

public class ObserverTest extends JFXTestCase {

    protected var subject:Subject;
    protected var observer:Observer;

    override public function setUp() {
        subject  = Subject{ weakReferenced: testWeakReferences };
        observer = Observer{};
    }
}

/**
 * Check the normal functionality
 */
public class HappyFlowTest extends ObserverTest {

    function testEmptyDispatch() {
        subject.dispatch( WakeupEvent{} );
        assertEquals( observer.wakeupEventCount, 0 );
        assertEquals( observer.sleepEventCount, 0 );
    }

    function testSimpleDispatch() {
        subject.addEventListener( EVENT_TYPE_WAKEUP, observer );
        subject.dispatch( WakeupEvent{} );
        assertEquals( observer.wakeupEventCount, 1 );
        assertEquals( observer.sleepEventCount, 0 );
    }

    function testFullDispatch() {
        // one subscription for each event
        subject.addEventListener( EVENT_TYPE_WAKEUP, observer );
        subject.addEventListener( EVENT_TYPE_SLEEP, observer );
        subject.dispatch( WakeupEvent{} );
        subject.dispatch( SleepEvent {} );
        assertEquals( observer.wakeupEventCount, 1 );
        assertEquals( observer.sleepEventCount, 1 );

        // clear counters
        observer.reset();
        assertEquals( observer.wakeupEventCount, 0 );
        assertEquals( observer.sleepEventCount, 0 );

        // unregister and try again. the unregistered observer shouldn't have
        // been notified
        subject.removeEventListener( EVENT_TYPE_SLEEP, observer);
        subject.dispatch( WakeupEvent{} );
        subject.dispatch( SleepEvent {} );
        assertEquals( observer.wakeupEventCount, 1 );
        assertEquals( observer.sleepEventCount, 0 );

        // unregister everything. the counters shouldn't have changed
        subject.removeEventListener( EVENT_TYPE_WAKEUP, observer);
        subject.dispatch( WakeupEvent{} );
        subject.dispatch( SleepEvent {} );
        assertEquals( observer.wakeupEventCount, 1 );
        assertEquals( observer.sleepEventCount, 0 );
    }

    function testSpeedDispatch() {
        subject.addEventListener( EVENT_TYPE_WAKEUP, observer );
        subject.addEventListener( EVENT_TYPE_SLEEP, observer );
        for ( count in [ 1 .. 100 ] ) {
            subject.dispatch( WakeupEvent{} );
            subject.dispatch( SleepEvent{} );
        }
        assertEquals( observer.wakeupEventCount, 100 );
        assertEquals( observer.sleepEventCount, 100 );
    }
};

/**
 * Check for the error conditions
 */
 public class ErrorConditionsTest extends ObserverTest {

     // trigger the validation error of duplicate event types
     function testDuplicateEventType() {
         try {
             def duplicateSubject = FaultySubject{};
             fail("The instantiation should have failed due to duplicate event types");
         } catch( ex:IllegalStateException ) {}
     }

     // trigger the validation errors when subscribing to events
     function testSubscriptionErrors() {
         // unknown event type
         try {
             subject.addEventListener("zozo", observer);
             fail("Passing an unknown event type should be blocked");
         } catch( ex:IllegalArgumentException ) {}
         // null observer
         try {
             subject.addEventListener(EVENT_TYPE_SLEEP, null);
             fail("Passing a null listener should be blocked");
         } catch( ex:IllegalArgumentException ) {}
         // both
         try {
             subject.addEventListener(null, null);
             fail("Passing invalid data should be blocked");
         } catch( ex:IllegalArgumentException ) {}
     }

     // trigger the validation errors when unsubscribing to events
     function testDispatchErrors() {
         // unknown event type
         try {
             subject.dispatch(UnknownEvent{});
             fail("Passing an unknown event type should be blocked");
         } catch( ex:IllegalArgumentException ) {}
         // null event type
         try {
             subject.dispatch( null );
             fail("Passing a null event should be blocked");
         } catch( ex:IllegalArgumentException ) {}
         // both
         try {
             subject.dispatch(NullEvent{});
             fail("Passing invalid data should be blocked");
         } catch( ex:IllegalArgumentException ) {}
     }
}


 public class WeakReferenceTest extends ObserverTest {
     override function setUp() :Void {
         subject = Subject { weakReferenced: true };
     }

     function testReferenceRelease() :Void {
        // set up 10,000 listeners for the subject
        var listeners = for ( index in [ 1 .. 10000 ] ) {
            WeakObserver {

            }
        }
        for ( listener in listeners ) {
            subject.addEventListener(EVENT_TYPE_SLEEP, listener);
        }

        // dispatch the event to the 10,000
        def event = SleepEvent{};
        subject.dispatch(event);
        assertEquals( weakEventCounter, 10000 );

        // remove the hard references
        delete listeners;

        // encourage the garbage collector to run by asking for a big bunch of memory
        // and requesting a collect.
        def wastedMemory = for ( index in [ 1 .. 10000000 ] ) { 120 };
        System.gc();
        System.gc();

        // dispatch the event - no listener should be listening any more
        weakEventCounter = 0;
        subject.dispatch(event);
        assertEquals( 0, weakEventCounter );
     }
 }

/**
 * Observer class to test the weak references. It will update an
 * external counter instead of a local variable.
 */
class WeakObserver extends EventListener {
    override public function handleEvent (event : Event) : Void {
        weakEventCounter++;
    }
}


/**
 * This is a class with a null for the internal type value.
 * Dispatching such type should be blocked.
 */
class NullEvent extends Event {
    override def type = null;
}

/**
 * This is an event of an unknown type. Dispatching this
 * should be blocked.
 */
class UnknownEvent extends Event {
    override def type = "helllloowwww";
}

/**
 * This is a class that will cause a conflict in the internal values of
 * of the event types. An exception is thrown as soon as an instance
 * is created.
 */
class FaultySubject extends Subject {
    init {
        insert [ EVENT_TYPE_WAKEUP, EVENT_TYPE_SLEEP ] into eventTypes;
    }
}

/**
 * Test domain model
 */
 
class Subject extends EventDispatcher {
    init {
        insert [ EVENT_TYPE_WAKEUP, EVENT_TYPE_SLEEP ] into eventTypes;
    }
}

class Observer extends EventListener {
    public-read var wakeupEventCount = 0;
    public-read var sleepEventCount  = 0;

    public function reset() :Void {
        wakeupEventCount = 0;
        sleepEventCount  = 0;
    }
    
    override public function handleEvent (event : Event): Void {
        if ( event instanceof WakeupEvent ) {
            wakeupEventCount++;
        }
        else if ( event instanceof SleepEvent ) {
            sleepEventCount++;
        }
        else {
            throw new UnsupportedOperationException('Unexpected event type {event.type}');
        }
    }
}

class WakeupEvent extends Event {
    override def type = EVENT_TYPE_WAKEUP;
};

class SleepEvent extends Event {
    override def type = EVENT_TYPE_SLEEP;
};

public function run() :Void {
    def runner = TestRunner{};

    {
        // add tests for hard referencing and weak referencing. Both should work the same
        testWeakReferences = false;
        def suite          = TestSuite{};
        suite.addTest( HappyFlowTest       { testFunction: "testEmptyDispatch" } );
        suite.addTest( HappyFlowTest       { testFunction: "testSimpleDispatch" } );
        suite.addTest( HappyFlowTest       { testFunction: "testFullDispatch" } );
        suite.addTest( HappyFlowTest       { testFunction: "testSpeedDispatch" } );
        suite.addTest( ErrorConditionsTest { testFunction: "testDuplicateEventType" } );
        suite.addTest( ErrorConditionsTest { testFunction: "testSubscriptionErrors" } );
        suite.addTest( ErrorConditionsTest { testFunction: "testDispatchErrors" } );

        for ( index in [ 1 .. 2 ] ) {
            runner.run( suite );
            testWeakReferences = true;
        }
    }

    {
        testWeakReferences = false;
        def suite          = TestSuite{};
        suite.addTest( WeakReferenceTest { testFunction: "testReferenceRelease" } );
        runner.run( suite );
    }
}

