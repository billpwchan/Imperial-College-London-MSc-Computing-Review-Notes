<?php

    /**
     * Build a SQL statement for a condition
     *
     * If $condition integer or string - exact value will be filtered ('eq' condition)
     *
     * If $condition is array is - one of the following structures is expected:
     * - array("eq" => $equalValue)
     * - array("neq" => $notEqualValue)
     * - array("like" => $likeValue)
     * - array("in" => array($inValues))
     * - array("nin" => array($notInValues))
     * - array("notnull" => $valueIsNotNull)
     * - array("null" => $valueIsNull)
     * - array("gt" => $greaterValue)
     * - array("lt" => $lessValue)
     * - array("gteq" => $greaterOrEqualValue)
     * - array("lteq" => $lessOrEqualValue)
     * - array("finset" => $valueInSet)
     * - array("regexp" => $regularExpression)
     * - array("from" => $fromValue, "to" => $toValue)
     * - array("seq" => $stringValue)
     * - array("sneq" => $stringValue)
     */

    public function prepareCondition($field, $condition)
    {
        $conds = [
            'eq'            => "{{field}} = ?",
            'neq'           => "{{field}} != ?",
            'like'          => "{{field}} LIKE ?",
            'nlike'         => "{{field}} NOT LIKE ?",
            'in'            => "{{field}} IN(?)",
            'nin'           => "{{field}} NOT IN(?)",
            'is'            => "{{field}} IS ?",
            'notnull'       => "{{field}} IS NOT NULL",
            'null'          => "{{field}} IS NULL",
            'gt'            => "{{field}} > ?",
            'lt'            => "{{field}} < ?",
            'gteq'          => "{{field}} >= ?",
            'lteq'          => "{{field}} <= ?",
            'finset'        => "FIND_IN_SET(?, {{field}})",
            'regexp'        => "{{field}} REGEXP ?",
            'from'          => "{{field}} >= ?",
            'to'            => "{{field}} <= ?",
            'seq'           => null,
            'sneq'          => null,
            'ntoa'          => "INET_NTOA({{field}}) LIKE ?",
        ];

        $query = '';
        if (is_array($condition)) {
            $key = key(array_intersect_key($condition, $conds));

            if (isset($condition['from']) || isset($condition['to'])) {
                if (isset($condition['from'])) {
                    $from  = $this->_prepareDateCondition($condition, 'from');
                    $query = $this->_conditionHelper($conds['from'], $from, $field);
                }

                if (isset($condition['to'])) {
                    $query .= empty($query) ? '' : ' AND ';
                    $to     = $this->_prepareDateCondition($condition, 'to');
                    $query = $this->_conditionHelper($query . $conds['to'], $to, $field);
                }
            } elseif (array_key_exists($key, $conds)) {
                $value = $condition[$key];
                if (($key == 'seq') || ($key == 'sneq')) {
                    $key = $this->_transformStringCondition($key, $value);
                }
                if (($key == 'in' || $key == 'nin') && is_string($value)) {
                    $value = explode(',', $value);
                }
                $query = $this->_conditionHelper($conds[$key], $value, $field);
            } else {
                $queries = [];
                foreach ($condition as $orCondition) {
                    $queries[] = sprintf('(%s)', $this->prepareCondition($field, $orCondition));
                }

                $query = sprintf('(%s)', implode(' OR ', $queries));
            }
        } else {
            $query = $this->_conditionHelper($conds['eq'], (string)$condition, $field);
        }

        return $query;
    }

    protected function _prepareDateCondition($condition, $key)
    {
        if (empty($condition['date'])) {
            if (empty($condition['datetime'])) {
                $result = $condition[$key];
            } else {
                $result = $this->formatDate($condition[$key]);
            }
        } else {
            $result = $this->formatDate($condition[$key]);
        }

        return $result;
    }

    protected function _conditionHelper($text, $value, $field)
    {
        $sql = $this->quoteInto($text, $value);
        $sql = str_replace('{{field}}', $field, $sql);
        return $sql;
    }

    protected function _transformStringCondition($conditionKey, $value)
    {
        $value = (string) $value;
        if ($value == '') {
            return ($conditionKey == 'seq') ? 'null' : 'notnull';
        } else {
            return ($conditionKey == 'seq') ? 'eq' : 'neq';
        }
    }

?>