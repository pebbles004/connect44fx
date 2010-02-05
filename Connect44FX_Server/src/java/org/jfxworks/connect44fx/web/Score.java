/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.jfxworks.connect44fx.web;

import com.google.appengine.api.datastore.Key;
import java.io.Serializable;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

/**
 *
 * @author jan
 */
@Entity
public class Score implements Serializable {
    private static final long serialVersionUID = 1L;

    public Score() {
    }

    public Score( String playerId, Integer score ) {
        setPlayerId( playerId );
        setScore( score );
    }
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Key id;

    private String playerId;

    private Integer score;

    public Key getId() {
        return id;
    }

    public void setId( Key id ) {
        this.id = id;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore( Integer score ) {
        this.score = score;
    }

    public String getPlayerId() {
        return playerId;
    }

    public void setPlayerId( String playerId ) {
        this.playerId = playerId;
    }

    @Override
    public boolean equals( Object obj ) {
        if ( obj == null ) {
            return false;
        }
        if ( getClass() != obj.getClass() ) {
            return false;
        }
        final Score other = (Score) obj;
        if ( this.id != other.id && ( this.id == null || !this.id.equals( other.id ) ) ) {
            return false;
        }
        if ( ( this.playerId == null ) ? ( other.playerId != null ) : !this.playerId.equals( other.playerId ) ) {
            return false;
        }
        if ( this.score != other.score && ( this.score == null || !this.score.equals( other.score ) ) ) {
            return false;
        }
        return true;
    }

    @Override
    public int hashCode() {
        int hash = 3;
        hash = 59 * hash + ( this.id != null ? this.id.hashCode() : 0 );
        hash = 59 * hash + ( this.playerId != null ? this.playerId.hashCode() : 0 );
        hash = 59 * hash + ( this.score != null ? this.score.hashCode() : 0 );
        return hash;
    }
}
