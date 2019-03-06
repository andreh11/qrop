#ifndef CORE_GLOBAL_H
#define CORE_GLOBAL_H

#include <QtCore/qglobal.h>

#if defined(CORE_LIBRARY)
#define CORESHARED_EXPORT Q_DECL_EXPORT
#else
#define CORESHARED_EXPORT Q_DECL_IMPORT
#endif

//#if defined(CORE_LIBRARY)
//#if defined(Q_OS_WIN)
//#define CORESHARED_EXPORT
//#else
//#define CORESHARED_EXPORT Q_DECL_EXPORT
//#endif
//#else
//#if defined(Q_OS_WIN)
//#define CORESHARED_EXPORT
//#else
//#define CORESHARED_EXPORT Q_DECL_IMPORT
//#endif
//#endif

#endif // CORE_GLOBAL_H
