module bible.chapter;

import bible.verse;

class Chapter {
	string m_chapterTitle;
	Verse[] m_verses;
	this( string chapterTitle ) {
		m_chapterTitle = chapterTitle;
	}
}
