/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Messaging Framework.
**
** $QT_BEGIN_LICENSE:LGPL$
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions
** contained in the Technology Preview License Agreement accompanying
** this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights.  These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
**
**
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QMAILTHREADKEY_H
#define QMAILTHREADKEY_H

#include "qmaildatacomparator.h"
#include "qmailkeyargument.h"
#include <QList>
#include <QSharedData>
#include "qmailid.h"
#include <QVariant>
#include "qmailipc.h"
#include "qmailglobal.h"

class QMailAccountKey;

class QMailThreadKeyPrivate;
class QMailMessageKey;

template <typename Key>
class MailKeyImpl;

class QMF_EXPORT QMailThreadKey
{
public:
    enum Property
    {
        Id = (1 << 0),
        ServerUid = (1 << 1),
        MessageCount = (1 << 2),
        UnreadCount = (1 << 3),
        Custom = (1 << 4), // This is for internal use only. It will be removed without notice
        Includes = (1 << 5),
        ParentAccountId = (1 << 6)
    };

    typedef QMailThreadId IdType;
    typedef QMailKeyArgument<Property> ArgumentType;

    QMailThreadKey();
    QMailThreadKey(const QMailThreadKey& other);
    virtual ~QMailThreadKey();

    QMailThreadKey operator~() const;
    QMailThreadKey operator&(const QMailThreadKey& other) const;
    QMailThreadKey operator|(const QMailThreadKey& other) const;
    const QMailThreadKey& operator&=(const QMailThreadKey& other);
    const QMailThreadKey& operator|=(const QMailThreadKey& other);

    bool operator==(const QMailThreadKey& other) const;
    bool operator !=(const QMailThreadKey& other) const;

    const QMailThreadKey& operator=(const QMailThreadKey& other);

    bool isEmpty() const;
    bool isNonMatching() const;
    bool isNegated() const;

    // for subqueries
    operator QVariant() const;

    const QList<ArgumentType> &arguments() const;
    const QList<QMailThreadKey> &subKeys() const;

    QMailKey::Combiner combiner() const;

    template <typename Stream> void serialize(Stream &stream) const;
    template <typename Stream> void deserialize(Stream &stream);

    static QMailThreadKey nonMatchingKey();

    static QMailThreadKey id(const QMailThreadId &id, QMailDataComparator::EqualityComparator cmp = QMailDataComparator::Equal);
    static QMailThreadKey id(const QMailThreadIdList &ids, QMailDataComparator::InclusionComparator cmp = QMailDataComparator::Includes);
    static QMailThreadKey id(const QMailThreadKey &key, QMailDataComparator::InclusionComparator cmp = QMailDataComparator::Includes);

    static QMailThreadKey serverUid(const QString &uid, QMailDataComparator::EqualityComparator cmp = QMailDataComparator::Equal);
    static QMailThreadKey serverUid(const QString &uid, QMailDataComparator::InclusionComparator cmp);
    static QMailThreadKey serverUid(const QStringList &uids, QMailDataComparator::InclusionComparator cmp = QMailDataComparator::Includes);

    static QMailThreadKey includes(const QMailMessageIdList &ids, QMailDataComparator::InclusionComparator cmp = QMailDataComparator::Includes);
    static QMailThreadKey includes(const QMailMessageKey &key, QMailDataComparator::InclusionComparator cmp = QMailDataComparator::Includes);

    static QMailThreadKey parentAccountId(const QMailAccountId &id, QMailDataComparator::EqualityComparator cmp = QMailDataComparator::Equal);
    static QMailThreadKey parentAccountId(const QMailAccountIdList &ids, QMailDataComparator::InclusionComparator cmp = QMailDataComparator::Includes);
    static QMailThreadKey parentAccountId(const QMailAccountKey &key, QMailDataComparator::InclusionComparator cmp = QMailDataComparator::Includes);

private:
    QMailThreadKey(Property p, const QVariant& value, QMailKey::Comparator c);

    template <typename ListType>
    QMailThreadKey(const ListType &valueList, Property p, QMailKey::Comparator c);

    friend class QMailThreadKeyPrivate;
    friend class MailKeyImpl<QMailThreadKey>;

    QSharedDataPointer<QMailThreadKeyPrivate> d;
};

Q_DECLARE_USER_METATYPE(QMailThreadKey)

#endif
