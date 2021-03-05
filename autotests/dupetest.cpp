/*
    Copyright 2016 Harald Sitter <sitter@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library. If not, see <http://www.gnu.org/licenses/>.
*/

#include <QObject>
#include <QProcess>
#include <QStandardPaths>
#include <QTest>

#include "testhelpers.h"

class DupeTest : public QObject
{
    Q_OBJECT

    void readLines(QProcess &proc)
    {
        QString line;
        while (proc.canReadLine() || proc.waitForReadyRead()) {
            line = proc.readLine();
            failListContent(line.simplified().split(QChar(' ')), "The following files are duplicates but not links:\n");
        }
    }

    void dupesForDirectory(const QString &path)
    {
        QProcess proc;
        proc.setProgram(QStringLiteral("fdupes"));
        proc.setArguments(QStringList() << QStringLiteral("--recurse") << QStringLiteral("--sameline") << QStringLiteral("--nohidden") << path);
        proc.start();
        proc.waitForStarted();
        readLines(proc);
    }

private Q_SLOTS:
    void test_duplicates()
    {
        if (QStandardPaths::findExecutable(QStringLiteral("fdupes")).isEmpty()) {
#ifdef Q_OS_WIN
            QSKIP("this test needs the fdupes binary (1.51+) to run");
#else
            // Fail and skip. This is a fairly relevant test, so it not running is a warning really.
            QFAIL("this test needs the fdupes binary (1.51+) to run");
#endif
        }
        for (auto dir : ICON_DIRS) {
            dupesForDirectory(PROJECT_SOURCE_DIR + QStringLiteral("/") + dir);
        }
    }
};

QTEST_GUILESS_MAIN(DupeTest)

#include "dupetest.moc"
