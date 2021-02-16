#ifndef CMDFAMILY_H
#define CMDFAMILY_H
#include "core_global.h"
class FamilyService;

class CmdFamily{
    friend class Qrop;

public:
    CmdFamily() = default;
    virtual ~CmdFamily() = default;

protected:
    static FamilyService *s_familySvc;
};

#endif // CMDFAMILY_H
