package org.jfxworks.connect44fx.servlet;

import java.io.IOException;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.jfxworks.connect44fx.dao.ScoreDao;
import org.jfxworks.connect44fx.entity.Score;

public class LoadScoreServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {		
		Logger log = Logger.getLogger(LoadScoreServlet.class.getName());
		log.severe("Loading score in loadscoreservlet");
		
		try {
			ScoreDao scoreDao = new ScoreDao();
			String userId = (String) req.getAttribute("userId");
			Score score = scoreDao.loadScoreByUser(userId);
			ServletOutputStream out = resp.getOutputStream();
			if(score != null) {
				out.write(score.getValue());
			} else {
				out.write(0);
			}
			out.close();
			log.severe("Loaded score in loadscoreservlet");
		} catch (Exception e) {
			log.throwing(LoadScoreServlet.class.getName(), "doGet", e);
			throw new ServletException(e);
		}
	}
}
