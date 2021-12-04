#
# This source file is part of the EdgeDB open source project.
#
# Copyright 2022-present MagicStack Inc. and the EdgeDB authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


## Range functions

# FIXME: Proof of concept range constructor.
CREATE FUNCTION
std::range(
    lower: optional int64 = {},
    upper: optional int64 = {},
    named only inclow: bool = true,
    named only inchigh: bool = false
) -> range<int64>
{
    SET volatility := 'Immutable';
    USING SQL $$
        SELECT CASE
            WHEN "inclow" AND "inchigh"
            THEN int8range("lower", "upper", '[]')
            WHEN NOT "inclow" AND "inchigh"
            THEN int8range("lower", "upper", '(]')
            WHEN NOT "inclow" AND NOT "inchigh"
            THEN int8range("lower", "upper", '()')
            WHEN "inclow" AND NOT "inchigh"
            THEN int8range("lower", "upper", '[)')
        END
    $$;
};


CREATE FUNCTION
std::range(
    lower: optional int32 = {},
    upper: optional int32 = {},
    named only inclow: bool = true,
    named only inchigh: bool = false
) -> range<int32>
{
    SET volatility := 'Immutable';
    USING SQL $$
        SELECT CASE
            WHEN "inclow" AND "inchigh"
            THEN int4range("lower", "upper", '[]')
            WHEN NOT "inclow" AND "inchigh"
            THEN int4range("lower", "upper", '(]')
            WHEN NOT "inclow" AND NOT "inchigh"
            THEN int4range("lower", "upper", '()')
            WHEN "inclow" AND NOT "inchigh"
            THEN int4range("lower", "upper", '[)')
        END
    $$;
};


CREATE FUNCTION std::range_get_upper(r: range<anypoint>) -> optional anypoint
{
    SET volatility := 'Immutable';
    USING SQL FUNCTION 'upper';
};


CREATE FUNCTION std::range_get_lower(r: range<anypoint>) -> optional anypoint
{
    SET volatility := 'Immutable';
    USING SQL FUNCTION 'lower';
};


CREATE FUNCTION std::range_is_inclusive_upper(r: range<anypoint>) -> std::bool
{
    SET volatility := 'Immutable';
    USING SQL FUNCTION 'upper_inc';
};


CREATE FUNCTION std::range_is_inclusive_lower(r: range<anypoint>) -> std::bool
{
    SET volatility := 'Immutable';
    USING SQL FUNCTION 'lower_inc';
};


CREATE FUNCTION std::contains(
    haystack: range<anypoint>,
    needle: range<anypoint>
) -> std::bool
{
    SET volatility := 'Immutable';
    USING SQL $$
       SELECT "haystack" @> "needle"
    $$;
};


CREATE FUNCTION std::contains(
    haystack: range<anypoint>,
    needle: anypoint
) -> std::bool
{
    SET volatility := 'Immutable';
    USING SQL $$
       SELECT "haystack" @> "needle"
    $$;
};


CREATE FUNCTION std::overlaps(
    l: range<anypoint>,
    r: range<anypoint>
) -> std::bool
{
    SET volatility := 'Immutable';
    USING SQL $$
       SELECT "l" && "r"
    $$;
};


## Range operators


CREATE INFIX OPERATOR
std::`=` (l: range<anypoint>, r: range<anypoint>) -> std::bool {
    CREATE ANNOTATION std::identifier := 'eq';
    CREATE ANNOTATION std::description := 'Compare two values for equality.';
    SET volatility := 'Immutable';
    SET recursive := true;
    SET commutator := 'std::=';
    SET negator := 'std::!=';
    USING SQL OPERATOR '=';
};


CREATE INFIX OPERATOR
std::`?=` (l: OPTIONAL range<anypoint>,
           r: OPTIONAL range<anypoint>) -> std::bool {
    CREATE ANNOTATION std::identifier := 'coal_eq';
    CREATE ANNOTATION std::description :=
        'Compare two (potentially empty) values for equality.';
    SET volatility := 'Immutable';
    USING SQL EXPRESSION;
    SET recursive := true;
};


CREATE INFIX OPERATOR
std::`!=` (l: range<anypoint>, r: range<anypoint>) -> std::bool {
    CREATE ANNOTATION std::identifier := 'neq';
    CREATE ANNOTATION std::description := 'Compare two values for inequality.';
    SET volatility := 'Immutable';
    SET recursive := true;
    SET commutator := 'std::!=';
    SET negator := 'std::=';
    USING SQL OPERATOR '<>';
};


CREATE INFIX OPERATOR
std::`?!=` (l: OPTIONAL range<anypoint>,
            r: OPTIONAL range<anypoint>) -> std::bool {
    CREATE ANNOTATION std::identifier := 'coal_neq';
    CREATE ANNOTATION std::description :=
        'Compare two (potentially empty) values for inequality.';
    SET volatility := 'Immutable';
    USING SQL EXPRESSION;
    SET recursive := true;
};


CREATE INFIX OPERATOR
std::`>=` (l: range<anypoint>, r: range<anypoint>) -> std::bool {
    CREATE ANNOTATION std::identifier := 'gte';
    CREATE ANNOTATION std::description := 'Greater than or equal.';
    SET volatility := 'Immutable';
    SET recursive := true;
    SET commutator := 'std::<=';
    SET negator := 'std::<';
    USING SQL OPERATOR '>=';
};


CREATE INFIX OPERATOR
std::`>` (l: range<anypoint>, r: range<anypoint>) -> std::bool {
    CREATE ANNOTATION std::identifier := 'gt';
    CREATE ANNOTATION std::description := 'Greater than.';
    SET volatility := 'Immutable';
    SET recursive := true;
    SET commutator := 'std::<';
    SET negator := 'std::<=';
    USING SQL OPERATOR '>';
};


CREATE INFIX OPERATOR
std::`<=` (l: range<anypoint>, r: range<anypoint>) -> std::bool {
    CREATE ANNOTATION std::identifier := 'lte';
    CREATE ANNOTATION std::description := 'Less than or equal.';
    SET volatility := 'Immutable';
    SET recursive := true;
    SET commutator := 'std::>=';
    SET negator := 'std::>';
    USING SQL OPERATOR '<=';
};


CREATE INFIX OPERATOR
std::`<` (l: range<anypoint>, r: range<anypoint>) -> std::bool {
    CREATE ANNOTATION std::identifier := 'lt';
    CREATE ANNOTATION std::description := 'Less than.';
    SET volatility := 'Immutable';
    SET recursive := true;
    SET commutator := 'std::>';
    SET negator := 'std::>=';
    USING SQL OPERATOR '<';
};


CREATE INFIX OPERATOR
std::`+` (l: range<anypoint>, r: range<anypoint>) -> range<anypoint> {
    CREATE ANNOTATION std::identifier := 'plus';
    CREATE ANNOTATION std::description := 'Range union.';
    SET volatility := 'Immutable';
    SET recursive := true;
    SET commutator := 'std::+';
    USING SQL OPERATOR r'+';
};


CREATE INFIX OPERATOR
std::`-` (l: range<anypoint>, r: range<anypoint>) -> range<anypoint> {
    CREATE ANNOTATION std::identifier := 'plus';
    CREATE ANNOTATION std::description := 'Range difference.';
    SET volatility := 'Immutable';
    SET recursive := true;
    USING SQL OPERATOR r'-';
};


CREATE INFIX OPERATOR
std::`*` (l: range<anypoint>, r: range<anypoint>) -> range<anypoint> {
    CREATE ANNOTATION std::identifier := 'plus';
    CREATE ANNOTATION std::description := 'Range intersection.';
    SET volatility := 'Immutable';
    SET recursive := true;
    SET commutator := 'std::*';
    USING SQL OPERATOR r'*';
};
