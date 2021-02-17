#ifndef CMDFAMILY_H
#define CMDFAMILY_H
#include "core_global.h"
class FamilyService;

class CmdFamily
{
    friend class Qrop;

public:
    CmdFamily() = default;
    virtual ~CmdFamily() = default;

    virtual QString str() const = 0;

protected:
    static FamilyService *s_familySvc;
};

#endif // CMDFAMILY_H
