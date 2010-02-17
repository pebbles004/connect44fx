/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.jfxworks.connect44fx.web;

import com.google.appengine.api.datastore.Key;
import java.io.Serializable;
import java.util.List;
import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;

/**
 *
 * @author jan
 */
@Entity
public class Game implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Key id;

    private String name;

    @OneToMany(cascade={CascadeType.ALL})
    private List<Score> scores;

    public Key getId() {
        return id;
    }

    public void setId( Key id ) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName( String name ) {
        this.name = name;
    }

    public List<Score> getScores() {
        return scores;
    }

    public void setScores( List<Score> scores ) {
        this.scores = scores;
    }

    @Override
    public boolean equals( Object obj ) {
        if ( obj == null ) {
            return false;
        }
        if ( getClass() != obj.getClass() ) {
            return false;
        }
        final Game other = (Game) obj;
        if ( this.id != other.id && ( this.id == null || !this.id.equals( other.id ) ) ) {
            return false;
        }
        if ( ( this.name == null ) ? ( other.name != null ) : !this.name.equals( other.name ) ) {
            return false;
        }
        return true;
    }

    @Override
    public int hashCode() {
        int hash = 3;
        hash = 29 * hash + ( this.id != null ? this.id.hashCode() : 0 );
        hash = 29 * hash + ( this.name != null ? this.name.hashCode() : 0 );
        return hash;
    }
}
